lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler'
Bundler.require

$stdout.sync = true

require 'tent-admin'
require 'securerandom'

map '/' do
  use Rack::Session::Cookie,  :key => 'tent-admin.session',
                              :expire_after => 2592000, # 1 month
                              :secret => ENV['SESSION_SECRET'] || SecureRandom.hex
  run TentAdmin.new
end
