$LOAD_PATH << File.expand_path("lib", __dir__)

require "note/version"

Gem::Specification.new do |spec|
  spec.name          = "notenote"
  spec.version       = Note::VERSION
  spec.authors       = ["Anatoli Makarevich"]
  spec.email         = ["makaroni4@gmail.com"]

  spec.summary       = "CLI tool to keep daily notes."
  spec.description   = "CLI tool to keep daily notes."
  spec.homepage      = "https://github.com/makaroni4/note"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] +
                       ["LICENSE.txt"]

  spec.executables   = ["note"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.3.22"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
