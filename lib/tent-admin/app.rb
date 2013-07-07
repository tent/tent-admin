require 'rack-putty'
require 'omniauth-tent'

module TentAdmin
  class App
    require 'tent-admin/app/middleware'
    require 'tent-admin/app/serialize_response'
    require 'tent-admin/app/asset_server'
    require 'tent-admin/app/render_view'
    require 'tent-admin/app/authentication'

    AssetServer.asset_roots = [
      File.expand_path('../../assets', __FILE__), # lib/assets
      File.expand_path('../../../vendor/assets', __FILE__) # vendor/assets
    ]

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

    match %r{\A/auth/tent(/callback)?} do |b|
      b.use OmniAuth::Builder do
        provider :tent, {
          :get_app => AppLookup,
          :on_app_created => AppCreate,
          :app => {
            :name => TentAdmin.settings[:name],
            :description => TentAdmin.settings[:description],
            :url => TentAdmin.settings[:display_url],
            :redirect_uri => TentAdmin.settings[:redirect_uri],
            :read_types => TentAdmin.settings[:read_types],
            :write_types => TentAdmin.settings[:write_types],
            :scopes => TentAdmin.settings[:scopes]
          }
        }
      end
      b.use OmniAuthCallback
    end

    post '/signout' do |b|
      b.use Signout
    end

    get '*' do |b|
      b.use Authentication
      b.use MainApplication
      b.use RenderView
    end
  end
end
