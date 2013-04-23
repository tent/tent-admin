# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tent-admin/version'

Gem::Specification.new do |spec|
  spec.name          = "tent-admin"
  spec.version       = TentAdmin::VERSION
  spec.authors       = ["Jesse Stuart"]
  spec.email         = ["jesse@jessestuart.ca"]
  spec.description   = %q{Admin app for Tent}
  spec.summary       = %q{Admin app for Tent}
  spec.homepage      = ""

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
