# frozen_string_literal: true

require "optparse"
require "json"
require "pp"
require "date"
require "byebug"
require "fileutils"
require "kramdown"
require "nokogiri"
require "uri"
require "erb"
require_relative "helpers"

$LOAD_PATH << File.expand_path(__dir__)

module Note
  class CLI
    include Helpers

    CONFIG_FILE_NAME = ".notenote"
    TMP_FOLDER = "/tmp/notenote"

    def run(args = [])
      if args.first == "init"
        notes_folder = args[1]

        if notes_folder.nil?
          puts "Provide a valid folder name, please. ☺️"
          return
        end

        if Dir.exists?(notes_folder)
          puts %(The folder named "#{notes_folder}" already exists. ☺️)
          return
        else
          Dir.mkdir(notes_folder)
        end

        vscode_config_folder = File.join(notes_folder, ".vscode")
        unless Dir.exists?(vscode_config_folder)
          Dir.mkdir(vscode_config_folder)
        end

        vscode_settings_file = File.join(vscode_config_folder, "settings.json")
        if File.exist?(vscode_settings_file)
          vscode_settings = JSON.parse(File.read(vscode_settings_file))

          vscode_settings["markdown.editor.drop.enabled"] = false

          File.open(vscode_settings_file, "w") do |f|
            f.puts(JSON.pretty_generate(vscode_settings))
          end
        else
          File.open(vscode_settings_file, "w") do |f|
            f.puts(JSON.pretty_generate({ "markdown.editor.drop.enabled": false }))
          end
        end

        notes_folder_full_path = File.join(Dir.pwd, notes_folder)

        create_config_file(notes_folder: notes_folder_full_path)
        create_readme_file
        create_note_file

        puts %(Your note folder "#{notes_folder}" and the first log file are created. You're ready to go! 🚀)

        0
      elsif args.first == "on"
        note_name = args[1..-1].join(" ") # "tax return" for `note on tax return``

        create_note_file(note_name: note_name)

        0
      elsif args.first == "all"
        notes_folder = notenote_config["notes_folder"]

        open_editor(path: notes_folder)

        0
      elsif args.first == "folder"
        unless mac?
          puts "Unfortunately, this command works only on Mac devices atm. Please, make a PR to support your OS. 🙏"
        end

        notes_folder = notenote_config["notes_folder"]

        osascript <<-END
          tell application "Terminal"
            activate
            tell application "System Events" to keystroke "t" using command down
            do script "cd #{notes_folder}" in front window
            do script "clear" in front window
          end tell
        END

        0
      elsif args.first == "pull"
        pull_notes
      elsif args.first == "push"
        push_notes

        0
      elsif args.first == "push!"
        push_notes(force: true)

        0
      elsif args.first == "version"
        puts Note::VERSION

        0
      elsif args.first == "random"
        notes_folder = notenote_config["notes_folder"]

        random_note = File.read(Dir[File.join(notes_folder, "**/*.md")].sample)

        random_note.gsub!(URI.regexp, '<\0>')

        note_template = File.read(File.join(File.dirname(__FILE__), "note.html.erb"))

        note_page = ERB.new(note_template).result_with_hash(
          note_name: Nokogiri::HTML(random_note).css("h1")&.text || "Random note",
          note_body: Kramdown::Document.new(random_note, parse_block_html: true).to_html
        )

        FileUtils.mkdir(TMP_FOLDER) unless Dir.exist?(TMP_FOLDER)

        FileUtils.cp_r(
          File.join(File.dirname(__FILE__), "assets"),
          File.join(TMP_FOLDER, "assets")
        )

        temp_note_file = File.join(TMP_FOLDER, "random.html")

        File.open(temp_note_file, "w") do |file|
          file.write(note_page)
        end

        system `open #{temp_note_file}`

        0
      elsif args.size == 0
        notes_folder = notenote_config["notes_folder"]

        today_folder = File.join(notes_folder, formatted_todays_date)
        today_note_file = File.join(today_folder, "#{notenote_config["default_note_file_name"]}.md")

        if File.exist?(today_note_file)
          open_editor(path: today_note_file)
        else
          create_note_file
        end

        0
      else
        puts "Hm, looks like there's no such command. 🤔"

        0
      end
    end

    private

    def create_readme_file
      notes_folder = notenote_config["notes_folder"]

      readme_file = File.join(notes_folder, "README.md")

      File.open(readme_file, "w") do |file|
        file.puts unindent <<-TEXT
          # Daily notes


        TEXT
      end
    end

    def create_config_file(notes_folder:)
      config_file = File.join(Dir.home, CONFIG_FILE_NAME)

      if File.exist?(config_file)
        puts "📢 You already have a config file: ~/#{CONFIG_FILE_NAME}"
        return
      end

      config_template = File.read(File.join(File.dirname(__FILE__), "config.json.template"))

      config = hash_format(config_template, {
        notes_folder: notes_folder
      })

      File.open(config_file, "w") do |f|
        f.puts(config)
      end
    end

    def create_note_file(note_name: notenote_config["default_note_file_name"])
      notes_folder = notenote_config["notes_folder"]

      today_folder = File.join(notes_folder, formatted_todays_date)

      Dir.mkdir(today_folder) unless Dir.exist?(today_folder)

      file_name = markdown_file_name(note_name: note_name)

      note_file = File.join(today_folder, file_name)

      if File.exist?(note_file)
        puts "This note already exists. ⚠️"
      else
        File.open(note_file, "w") do |file|
          file.puts unindent <<-TEXT
            # #{upcate_first(note_name)}


          TEXT
        end
      end

      open_editor(path: note_file)
    end

    def notenote_config
      config_file = File.join(Dir.home, CONFIG_FILE_NAME)

      JSON.parse(File.read(config_file))
    end

    def open_editor(path:)
      editor_command = notenote_config["editor_command"]

      system("#{editor_command} #{path}")
    end

    # This function parses the output of diffstat:
    #
    # git diff HEAD | diffstat -Cm
    #
    #  notes.md   |    2 ++
    #  testing.md |    5 ----!
    #  2 files changed, 2 insertions(+), 4 deletions(-), 1 modification(!)
    #
    # { "+" => 2, "-" => 4, "!" => 1}
    def git_diff_stat
      Dir.chdir(notenote_config["notes_folder"])

      raw_diffstat = `git diff HEAD | diffstat -Cm`

      raw_changes = raw_diffstat.split("\n").last.split(",").map(&:strip)

      raw_changes.each_with_object({}) do |change, o|
        next unless change =~ /[\+\-\!]/

        type = change.scan(/([\+\-\!])/)[0][0]
        num = change.scan(/\A(\d+)\s/)[0][0]

        o[type] = num
      end
    end

    def notes_changed_or_deleted?
      diff_stat = git_diff_stat

      diff_stat.member?("-") || diff_stat.member?("!")
    end

    def push_notes(force: false)
      if !force && notes_changed_or_deleted?
        puts "Some of the notes were mofified or deleted. Please, check them up and push manually."
        return
      end

      Dir.chdir(notenote_config["notes_folder"])

      system "git add ."

      system %(git commit -m "#{notenote_config["commit_message"]}")

      system "git push"

      puts "Pushed. ✅"
    end

    def pull_notes
      Dir.chdir(notenote_config["notes_folder"])

      system "git pull --ff-only"
    end

    def formatted_todays_date
      date_format = notenote_config["date_format"]

      Date.today.strftime(date_format)
    end
  end
end
