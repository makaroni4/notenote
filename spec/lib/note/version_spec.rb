require "spec_helper"

describe Note do
  it "has a version number" do
    expect(Note::VERSION).not_to be nil
  end
end
