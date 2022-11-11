require "spec_helper"
require_relative "../../../lib/note/helpers"

describe Helpers do
  describe "#hash_format" do
    subject :hash_format do
      object = Class.new { extend Helpers }

      object.send(:hash_format, str, hash)
    end

    context "replaces key references by hash values" do
      let(:str) { "90% %{foo} %{bar} %{foo}" }
      let(:hash) do
        {
          foo: "123",
          bar: "456"
        }
      end

      it { is_expected.to eq("90% 123 456 123") }
    end
  end
end
