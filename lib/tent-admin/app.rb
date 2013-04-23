require 'rack-putty'

module TentAdmin
  class App
    require 'tent-admin/app/middleware'
    require 'tent-admin/app/serialize_response'
    require 'tent-admin/app/asset_server'

    def self.settings
      @settings ||= Hash.new
    end

    def initialize(settings = {})
      self.class.settings.merge!(settings)
    end

    include Rack::Putty::Router

    stack_base SerializeResponse

    get '/assets/*' do |b|
      b.use AssetServer
    end
  end
end
