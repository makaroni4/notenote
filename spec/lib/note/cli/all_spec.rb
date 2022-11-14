require "spec_helper"
require_relative "../../../../lib/note/cli"
require_relative "./fake_fs_context"

describe Note::CLI do
  describe "note all" do
    include_context "fake_fs"

    subject :run do
      clone_config_file!

      cli.run(["init", notes_folder_name])

      cli.run(["all"])
    end

    let(:cli) { described_class.new }
    let(:notes_folder_name) { "my_notes" }
    let(:notes_folder) { File.join(Dir.pwd, notes_folder_name) }

    before do
      allow(cli).to receive(:system)
    end

    it "opens notes folder in VS Code" do
      FakeFS.with_fresh do
        expect(cli).to receive(:system).with("code #{notes_folder}")

        run
      end
    end
  end
end
