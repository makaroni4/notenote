require "spec_helper"
require_relative "../../../../lib/note/cli"

describe Note::CLI do
  describe "note init %FOLDER_NAME%" do
    subject :run do
      described_class.new.run(["init", notes_folder_name])
    end

    let(:notes_folder_name) { "my_notes" }
    let(:config_file) { File.join(Dir.home, described_class::CONFIG_FILE_NAME) }
    let(:config) { JSON.parse(File.read(config_file)) }

    it "creates a .notenote config file in the home directory" do
      FakeFS.with_fresh do
        config_template = File.expand_path("../../../../../lib/note/config.json.template", __FILE__)
        FakeFS::FileSystem.clone(config_template)

        run

        expect(config).to eq({
          "version" => 1,
          "notes_folder" => File.join(Dir.pwd, notes_folder_name),
          "date_format" => "%d-%m-%Y",
          "default_note_file_name" => "today",
          "editor_command" => "code",
          "commit_message" => "Added new notes"
        })
      end
    end
  end
end
