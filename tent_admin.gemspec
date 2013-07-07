# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tent-admin/version'

Gem::Specification.new do |gem|
  gem.name          = "tent-admin"
  gem.version       = TentAdmin::VERSION
  gem.authors       = ["Jesse Stuart"]
  gem.email         = ["jesse@jessestuart.ca"]
  gem.description   = %q{Admin app for Tent}
  gem.summary       = %q{Admin app for Tent}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rack-putty'
  gem.add_runtime_dependency 'mimetype-fu'
  gem.add_runtime_dependency 'sprockets', '~> 2.0'
  gem.add_runtime_dependency 'coffee-script'
  gem.add_runtime_dependency 'sass'
  gem.add_runtime_dependency 'marbles-js'
  gem.add_runtime_dependency 'lodash-assets'
  gem.add_runtime_dependency 'icing'
  gem.add_runtime_dependency 'omniauth-tent'
  gem.add_runtime_dependency 'pg'
  gem.add_runtime_dependency 'sequel'
  gem.add_runtime_dependency 'sequel-json'

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
end
