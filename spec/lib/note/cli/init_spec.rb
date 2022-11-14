require "spec_helper"
require_relative "../../../../lib/note/cli"
require_relative "../../../../lib/note/helpers"
require_relative "./fake_fs_context"

describe Note::CLI do
  describe "note init %FOLDER_NAME%" do
    include Helpers
    include_context "fake_fs"

    subject :run do
      clone_config_file!

      cli.run(["init", notes_folder_name])
    end

    let(:cli) { described_class.new }
    let(:notes_folder_name) { "my_notes" }
    let(:notes_folder) { File.join(Dir.pwd, notes_folder_name) }
    let(:today_note_file) { File.join(notes_folder, Date.today.strftime("%d-%m-%Y"), "today.md") }

    before do
      allow(cli).to receive(:system)
    end

    it "creates a .notenote config file in the home directory" do
      FakeFS.with_fresh do
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
        expect(File.read(today_note_file)).to eq("# Today\n")
      end
    end

    it "opens today's note in VS Code" do
      FakeFS.with_fresh do
        expect(cli).to receive(:system).with("code #{today_note_file}")

        run
      end
    end

    it "creates a README file" do
      FakeFS.with_fresh do
        run

        readme_file = File.join(Dir.pwd, notes_folder_name, "README.md")

        expect(File).to exist(readme_file)
      end
    end
  end
end
