# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awesome_tracer/version'

Gem::Specification.new do |spec|
  spec.name          = "awesome_tracer"
  spec.version       = AwesomeTracer::VERSION
  spec.authors       = ["svs"]
  spec.email         = ["svs@svs.io"]
  spec.summary       = %q{Sends RSpec traces to a web frontend over faye}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "awesome_print"
  spec.add_dependency "sinatra"
  spec.add_dependency "faye"
  spec.add_dependency "foreman"
  spec.add_dependency "thin"
  spec.add_dependency "slim"
  spec.add_dependency "event_machine"



  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-legacy_formatters"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "simplecov"
end
