require "spec_helper"
require_relative "../../lib/note/helpers"

describe Helpers do
  describe "#markdown_file_name" do
    subject :markdown_file_name do
      object = Class.new { extend Helpers }

      object.send(:markdown_file_name, note_name: note_name)
    end

    context "for a name with capital letters and spaces" do
      let(:note_name) { "Foo Bar" }

      it { is_expected.to eq("foo_bar.md") }
    end

    context "for a name with punctuation symbols" do
      let(:note_name) { "foo, bar; -  foo bar!?" }

      it { is_expected.to eq("foo_bar_foo_bar.md") }
    end
  end
end
