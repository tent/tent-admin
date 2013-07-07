require 'rack-putty'
require 'omniauth-tent'

module TentAdmin
  class App
    require 'tent-admin/app/middleware'
    require 'tent-admin/app/serialize_response'
    require 'tent-admin/app/asset_server'
    require 'tent-admin/app/render_view'
    require 'tent-admin/app/authentication'
    require 'tent-admin/app/oauth'

    def self.settings
      @settings ||= Hash.new
    end

    def initialize(settings = {})
      self.class.settings.merge!(settings)
    end

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
            :name => "Tent Admin",
            :description => "Tent Server Admin App",
            :url => ENV['URL'],
            :redirect_uri => "#{ENV['URL'].sub(%r{/\Z}, '')}/auth/tent/callback",
            :read_post_types => %w(
              https://tent.io/types/app/v0#
              https://tent.io/types/app-auth/v0#
              https://tent.io/types/credentials/v0#
              https://tent.io/types/basic-profile/v0#
            ),
            :write_post_types => %w(
              https://tent.io/types/app/v0#
              https://tent.io/types/app-auth/v0#
              https://tent.io/types/credentials/v0#
              https://tent.io/types/meta/v0#
              https://tent.io/types/basic-profile/v0#
            ),
            :scopes => %w()
          }
        }
      end
      b.use OmniAuthCallback
    end

    get '/oauth' do |b|
      b.use Authentication
      b.use OAuthConfirm
      b.use RenderView
    end

    post '/oauth' do |b|
      b.use Authentication
      b.use OAuthAuthorize
    end

    get '/signout' do |b|
      b.use Signout
    end

    get %r{/((profile)|(apps))?} do |b|
      b.use Authentication
      b.use MainApplication
      b.use RenderView
    end
  end
end
