shared_context "fake_fs" do
  let(:config_file) { File.join(Dir.home, described_class::CONFIG_FILE_NAME) }
  let(:config) { JSON.parse(File.read(config_file)) }

  private

  def clone_config_file!
    config_template = File.expand_path("../../../../../lib/note/config.json.template", __FILE__)

    FakeFS::FileSystem.clone(config_template)
  end
end
