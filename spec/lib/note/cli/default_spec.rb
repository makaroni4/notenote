require "spec_helper"
require_relative "../../../../lib/note/cli"
require_relative "./fake_fs_context"

describe Note::CLI do
  describe "note" do
    include_context "fake_fs"

    subject :run do
      clone_config_file!

      cli.run(["init", notes_folder_name])

      cli.run(["on"])
    end

    let(:cli) { described_class.new }
    let(:notes_folder_name) { "my_notes" }
    let(:notes_folder) { File.join(Dir.pwd, notes_folder_name) }
    let(:today_note_file) { File.join(notes_folder, Date.today.strftime("%d-%m-%Y"), "today.md") }

    before do
      allow(cli).to receive(:system)
    end

    it "creates today's note file" do
      FakeFS.with_fresh do
        run

        expect(File).to exist(today_note_file)
      end
    end

    it "opens today's note in VS Code" do
      FakeFS.with_fresh do
        expect(cli).to receive(:system).with("code #{today_note_file}")

        run
      end
    end
  end
end
