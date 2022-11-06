# frozen_string_literal: true

require "optparse"
require "json"

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
        file_name = note_name.gsub(/[^a-z0-9\-]+/, "_")

        create_note_file(file_name: "#{file_name}.md")

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
      else
        puts "Hm, I don't know this command 🤔"

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

      config = config_template % {
        notes_folder: notes_folder
      }

      config_file = File.join(Dir.home, ".notenote")

      File.open(config_file, "w") do |f|
        f.puts(config)
      end
    end

    def create_note_file(file_name: "notes.md")
      notes_folder = notenote_config["notes_folder"]

      today_folder = File.join(notes_folder, Time.now.strftime("%d-%m-%Y"))

      Dir.mkdir(today_folder) unless Dir.exist?(today_folder)

      note_file = File.join(today_folder, file_name)

      FileUtils.touch(note_file)

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
  end
end
