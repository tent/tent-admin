require 'yaml'
require 'mimetype_fu'
require 'sprockets'
require 'coffee_script'
require 'sass'
require 'marbles-js'
require 'icing'

module TentAdmin
  class App
    class AssetServer < Middleware

      module SprocketsHelpers
        AssetNotFoundError = Class.new(StandardError)
        def asset_path(source, options = {})
          asset = environment.find_asset(source)
          raise AssetNotFoundError.new("#{source.inspect} does not exist within #{environment.paths.inspect}!") unless asset
          "./#{asset.digest_path}"
        end
      end

      DEFAULT_MIME = 'application/octet-stream'.freeze

      class << self
        attr_accessor :asset_root, :logfile
      end

      def self.sprockets_environment
        @environment ||= begin
          environment = Sprockets::Environment.new do |env|
            env.logger = Logger.new(@logfile || STDOUT)
            env.context_class.class_eval do
              include SprocketsHelpers
            end
          end

          paths = %w[ javascripts stylesheets images fonts ]
          paths.each do |path|
            environment.append_path(File.join(@asset_root, path))
          end

          MarblesJS.sprockets_setup(environment)
          Icing::Sprockets.setup(environment)

          environment
        end
      end

      def initialize(app, options = {})
        super

        @public_dir = @options[:public_dir] || App.settings[:public_dir] || File.expand_path('../../../../public', __FILE__) # lib/../public

        @sprockets_environment = self.class.sprockets_environment
      end

      def action(env)
        asset_name = env['params'][:splat]
        compiled_path = File.join(@public_dir, asset_name)

        if File.exists?(compiled_path)
          [200, { 'Content-Type' => asset_mime_type(asset_name) }, [File.read(path)]]
        else
          new_env = env.clone
          new_env["PATH_INFO"] = env["REQUEST_PATH"].sub(%r{\A/assets}, '')
          @sprockets_environment.call(new_env)
        end
      end

      private

      def asset_mime_type(asset_name)
        mime = File.mime_type?(asset_name)
        mime == 'unknown/unknown' ? DEFAULT_MIME : mime
      end

    end
  end
end
