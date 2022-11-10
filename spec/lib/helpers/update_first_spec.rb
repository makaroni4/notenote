require "spec_helper"
require_relative "../../../lib/note/helpers"

describe Helpers do
  describe "#upcate_first" do
    subject :upcate_first do
      object = Class.new { extend Helpers }

      object.send(:upcate_first, str)
    end

    context "for nil" do
      let(:str) { nil }

      it { is_expected.to eq(nil) }
    end

    context "for an emptry string" do
      let(:str) { "" }

      it { is_expected.to eq("") }
    end

    context "for a lowercase string" do
      let(:str) { "foo Bar" }

      it { is_expected.to eq("Foo Bar") }
    end

    context "for an uppercase string" do
      let(:str) { "FOO BAR" }

      it { is_expected.to eq("FOO BAR") }
    end
  end
end
