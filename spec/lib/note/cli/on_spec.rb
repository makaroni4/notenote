require "spec_helper"
require_relative "../../../../lib/note/cli"
require_relative "./fake_fs_context"

describe Note::CLI do
  describe "note on %NOTE% %NAME%" do
    include_context "fake_fs"

    subject :run do
      clone_config_file!

      cli.run(["init", notes_folder_name])

      cli.run(["on", "transformer", "neural", "networks"])
    end

    let(:cli) { described_class.new }
    let(:notes_folder_name) { "my_notes" }
    let(:notes_folder) { File.join(Dir.pwd, notes_folder_name) }
    let(:note_file) { File.join(notes_folder, Date.today.strftime("%d-%m-%Y"), "transformer_neural_networks.md") }

    before do
      allow(cli).to receive(:system)
    end

    it "creates a note file" do
      FakeFS.with_fresh do
        run

        expect(File).to exist(note_file)
        expect(File.read(note_file)).to eq("# Transformer neural networks\n")
      end
    end

    it "opens a note in VS Code" do
      FakeFS.with_fresh do
        expect(cli).to receive(:system).with("code #{note_file}")

        run
      end
    end
  end
end
