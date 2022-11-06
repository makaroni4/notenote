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

        create_config_file(notes_folder: notes_folder)
        create_note_file

        puts %(Your note folder "#{notes_folder}" and the first log file are created. You're ready to go! 🚀)

        0
      elsif args.first == "on"
        note_name = args[1..-1].join(" ") # "tax return" for `note on tax return``
        file_name = note_name.gsub(/[^a-z0-9\-]+/, "_")

        create_note_file(file_name: "#{file_name}.md")

        0
      else
        puts "Hm, I don't know this command 🤔"

        0
      end
    end

    private

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

      open_editor(file: note_file)
    end

    def notenote_config
      config_file = File.join(Dir.home, ".notenote")

      JSON.parse(File.read(config_file))
    end

    def open_editor(note_file:)
      editor_command = notenote_config["editor_command"]

      system("#{editor_command} #{note_file}")
    end
  end
end
