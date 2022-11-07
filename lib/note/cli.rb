# frozen_string_literal: true

require "optparse"
require "json"
require "date"

$LOAD_PATH << File.expand_path(__dir__)

module Note
  class CLI
    def run(args = [])
      if args.first == "init"
        require "fileutils"

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
      else
        notes_folder = notenote_config["notes_folder"]

        today_folder = File.join(notes_folder, formatted_todays_date)
        today_note_file = File.join(today_folder, "#{notenote_config["default_note_file_name"]}.md")

        if File.exist?(today_note_file)
          open_editor(path: today_note_file)
        else
          create_note_file
        end

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
      config_template = File.read(File.join(File.dirname(__FILE__), "config.json.template"))

      config = safe_tt(config_template, {
        notes_folder: notes_folder
      })

      config_file = File.join(Dir.home, ".notenote")

      File.open(config_file, "w") do |f|
        f.puts(config)
      end
    end

    def create_note_file(note_name: "#{notenote_config["default_note_file_name"]}.md")
      notes_folder = notenote_config["notes_folder"]

      today_folder = File.join(notes_folder, formatted_todays_date)

      Dir.mkdir(today_folder) unless Dir.exist?(today_folder)

      file_name = note_name.strip.downcase.
        gsub(/[^a-z0-9\-]+/, "_").
        gsub(/\A\_+/, "").
        gsub(/\_+\z/, "").
        concat(".md")
      note_file = File.join(today_folder, file_name)

      if File.exist?(note_file)
        puts "This note already exists. ⚠️"
      else
        File.open(note_file, "w") do |file|
          file.puts unindent <<-TEXT
            # #{note_name}


          TEXT
        end
      end

      open_editor(path: note_file)
    end

    def notenote_config
      config_file = File.join(Dir.home, ".notenote")

      JSON.parse(File.read(config_file))
    end

    def open_editor(path:)
      editor_command = notenote_config["editor_command"]

      system("#{editor_command} #{path}")
    end

    def mac?
      RbConfig::CONFIG["host_os"] =~ /darwin/
    end

    def osascript(script)
      system "osascript", *unindent(script).split(/\n/).map { |line| ['-e', line] }.flatten
    end

    def unindent(str)
      str.gsub(/^#{str.scan(/^[ \t]+(?=\S)/).min}/, "")
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

    # A custom string format method to avoid type
    # errors when using str % hash.
    def safe_tt(str, hash)
      str_copy = str

      hash.each do |key, value|
        str_copy.gsub!("%{#{key}}", value.to_s)
      end

      str_copy
    end

    def formatted_todays_date
      date_format = notenote_config["date_format"]

      Date.today.strftime(date_format)
    end
  end
end
