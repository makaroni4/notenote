# frozen_string_literal: true

require "optparse"

$LOAD_PATH << File.expand_path(__dir__)

module Note
  class CLI
    def run(args = [])
      if args.first == "init"
        require "fileutils"

        folder_name = args[1]

        if folder_name.nil?
          puts "Provide a valid folder name, please. ☺️"
          return
        end

        if Dir.exists?(folder_name)
          puts %(The folder named "#{folder_name}" already exists. ☺️)
          return
        end

        Dir.mkdir(folder_name)
        FileUtils.touch(File.join(folder_name, Time.now.strftime("%d-%m-%Y.md")))
        puts %(Your note folder "#{folder_name}" and the first \
          log file are created. You're ready to go! 🚀)

        0
      else
        puts "Hm, I don't know this command 🤔"
      end
    end
  end
end
