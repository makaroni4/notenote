require "spec_helper"
require_relative "../../../lib/note/helpers"

describe Helpers do
  describe "#unindent" do
    subject :unindent do
      object = Class.new { extend Helpers }

      object.send(:unindent, str)
    end

    context "when multiple lines are indented with spaces" do
      let(:str) { "  foo\n  bar" }

      it { is_expected.to eq("foo\nbar") }
    end

    context "when multiple lines are indented with tabs" do
      let(:str) { "\t\tfoo\n\t\tbar" }

      it { is_expected.to eq("foo\nbar") }
    end

    context "when multiple lines are indented with an equal number of spaces and tabs" do
      let(:str) { "  \t\tfoo\n  \t\tbar" }

      it { is_expected.to eq("foo\nbar") }

      it "does not mutate str argument" do
        unindent

        expect(str).to eq("  \t\tfoo\n  \t\tbar")
      end
    end

    context "when multiple lines are indented with a non matching pattern of spaces and tabs" do
      let(:str) { "\t\t  foo\n  \t\tbar" }

      it { is_expected.to eq("\t\t  foo\n  \t\tbar") }
    end

    context "when argument is nil" do
      let(:str) { nil }

      it { is_expected.to eq(nil) }
    end

    context "when argument is an empty string" do
      let(:str) { "" }

      it { is_expected.to eq("") }
    end
  end
end
