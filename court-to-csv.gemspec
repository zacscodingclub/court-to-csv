# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'court-to-csv/version'

Gem::Specification.new do |spec|
  spec.name          = "court-to-csv"
  spec.version       = CourtToCSV::VERSION
  spec.authors       = ["zacscodingclub"]
  spec.email         = ["zbaston@gmail.com"]

  spec.summary       = "Scrapes court arrest data and outputs as CSV"
  spec.description   = "Not going public with this, so it probably doesn't quite matter.."
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10.4"

  spec.add_dependency "nokogiri", "~> 1.6.8"
  spec.add_dependency "mechanize", "~> 2.7.3"
  spec.add_dependency "require_all", "~> 1.3.3"
end
