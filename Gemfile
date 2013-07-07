source 'https://rubygems.org'
ruby '1.9.3'

# Specify your gem's dependencies in tent_admin.gemspec
gemspec

gem 'puma'

gem 'rack-putty', :git => 'git://github.com/tent/rack-putty.git', :branch => 'master'
gem 'marbles-js', :git => 'git://github.com/jvatic/marbles-js.git', :branch => 'master'
gem 'icing', :git => 'git://github.com/tent/icing.git', :branch => 'master'

group :development, :assets do
  gem 'asset_sync', :git => 'git://github.com/titanous/asset_sync.git', :branch => 'fix-mime'
  gem 'mime-types'
  gem 'yui-compressor'
end
