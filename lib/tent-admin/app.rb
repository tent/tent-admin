require 'rack-putty'

module TentAdmin
  class App
    require 'tent-admin/app/middleware'
    require 'tent-admin/app/serialize_response'
    require 'tent-admin/app/asset_server'
    require 'tent-admin/app/render_view'

    def self.settings
      @settings ||= Hash.new
    end

    def initialize(settings = {})
      self.class.settings.merge!(settings)
    end

    AssetServer.asset_root = File.expand_path('../../assets', __FILE__) # lib/assets

    include Rack::Putty::Router

    stack_base SerializeResponse

    class MainApplication < Middleware
      def action(env)
        env['response.view'] = 'application'
        env
      end
    end

    class Favicon < Middleware
      def action(env)
        env['REQUEST_PATH'].sub!(%r{/favicon}, "/assets/favicon")
        env['params'][:splat] = 'favicon.ico'
        env
      end
    end

    get '/assets/*' do |b|
      b.use AssetServer
    end

    get '/favicon.ico' do |b|
      b.use Favicon
      b.use AssetServer
    end

    get %r{/((profile)|(apps))?} do |b|
      b.use MainApplication
      b.use RenderView
    end
  end
end
