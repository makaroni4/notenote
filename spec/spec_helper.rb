require "bundler/setup"
require "byebug"
require "note"
require "fakefs/spec_helpers"

if ENV["TRAVIS"]
  require "coveralls"
  Coveralls.wear!
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FakeFS::SpecHelpers
end
