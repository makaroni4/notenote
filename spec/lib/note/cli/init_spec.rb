require "spec_helper"
require_relative "../../../../lib/note/cli"

describe Note::CLI do
  describe "note init %FOLDER_NAME%" do
    subject :run do
      clone_config_file!

      described_class.new.run(["init", notes_folder_name])
    end

    let(:notes_folder_name) { "my_notes" }
    let(:config_file) { File.join(Dir.home, described_class::CONFIG_FILE_NAME) }
    let(:config) { JSON.parse(File.read(config_file)) }
    let(:notes_folder) { File.join(Dir.pwd, notes_folder_name) }
    let(:today_note_file) { File.join(notes_folder, Date.today.strftime("%d-%m-%Y"), "today.md") }

    before do
      allow_any_instance_of(described_class).to receive(:system).with("code #{today_note_file}")
    end

    it "creates a .notenote config file in the home directory" do
      FakeFS.with_fresh do
        clone_config_file!

        run

        expect(config).to eq({
          "version" => 1,
          "notes_folder" => notes_folder,
          "date_format" => "%d-%m-%Y",
          "default_note_file_name" => "today",
          "editor_command" => "code",
          "commit_message" => "Added new notes"
        })
      end
    end

    it "creates a notes folder" do
      FakeFS.with_fresh do
        run

        expect(File).to exist(notes_folder)
      end
    end

    it "creates a default note in today's folder" do
      FakeFS.with_fresh do
        run

        expect(File).to exist(today_note_file)
      end
    end

    private

    def clone_config_file!
      config_template = File.expand_path("../../../../../lib/note/config.json.template", __FILE__)

      FakeFS::FileSystem.clone(config_template)
    end
  end
end
