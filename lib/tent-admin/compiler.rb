require 'tent-admin'

module TentAdmin
  module Compiler
    extend self

    ASSET_NAMES = %w(
      icing.css
      application.css
      application.js
    ).freeze

    attr_accessor :sprockets_environment, :assets_dir, :layout_dir, :layout_path, :layout_env, :compile_icing, :compile_marbles

    def configure_app(options = {})
      return if @app_configured

      # Load configuration
      TentAdmin.configure(options)

      @app_configured = true
    end

    def configure_sprockets(options = {})
      return if @sprockets_configured

      configure_app

      # Setup Sprockets Environment
      require 'rack-putty'
      require 'tent-admin/app/middleware'
      require 'tent-admin/app/asset_server'

      gem_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      TentAdmin::App::AssetServer.asset_roots = %w( lib/assets vendor/assets ).map do |path|
        File.join(gem_root, path)
      end

      TentAdmin::App::AssetServer.logfile = STDOUT

      self.sprockets_environment = TentAdmin::App::AssetServer.sprockets_environment

      if options[:compress]
        # Setup asset compression
        require 'uglifier'
        require 'sprockets-rainpress'
        sprockets_environment.js_compressor = Uglifier.new
        sprockets_environment.css_compressor = Sprockets::Rainpress
      end

      self.assets_dir ||= TentAdmin.settings[:public_dir]

      @sprockets_configured = true
    end

    def configure_layout
      return if @layout_configured

      configure_sprockets

      self.layout_dir ||= File.expand_path(File.join(assets_dir, '..'))
      self.layout_path ||= File.join(layout_dir, 'admin.html')
      system  "mkdir -p #{layout_dir}"

      self.layout_env ||= {
        'response.view' => 'application'
      }

      @layout_configured = true
    end

    def compile_assets(options = {})
      configure_sprockets(options)

      manifest = Sprockets::Manifest.new(
        sprockets_environment,
        assets_dir,
        File.join(assets_dir, "manifest.json")
      )

      others = []
      if self.compile_icing
        require 'icing/compiler'
        others += Icing::Compiler::ASSET_NAMES
      end

      if self.compile_marbles
        require 'marbles-js/compiler'
        others += MarblesJS::Compiler::ASSET_NAMES + MarblesJS::Compiler::VENDOR_ASSET_NAMES
      end

      manifest.compile(ASSET_NAMES + others)
    end

    def compress_assets
      compile_assets(:compress => true)
    end

    def gzip_assets
      compress_assets

      Dir["#{assets_dir}/**/*.*"].reject { |f| f =~ /\.gz\z/ }.each do |f|
        system "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
      end
    end

    def compile_layout(options = {})
      puts "Compiling layout..."

      configure_layout

      # compile 2 versions of the layout
      # the first (default) with the app nav
      # and the second (public facing) without
      [false, true].each do |is_public|
        if is_public
          layout_path = self.layout_path.sub(/(.+)\.html/) { "#{$1}_public.html" }
        else
          layout_path = self.layout_path
        end
        TentAdmin.settings[:render_app_nav] = !is_public

        require 'tent-admin/app'
        status, headers, body = TentAdmin::App::RenderView.new(lambda {}).call(layout_env)

        system "rm #{layout_path}" if File.exists?(layout_path)
        File.open(layout_path, "w") do |file|
          file.write(body.first)
        end

        if options[:gzip]
          system "gzip -c #{layout_path} > #{layout_path}.gz"
        end

        puts "Layout compiled to #{layout_path}"
      end
    end

    def gzip_layout
      compile_layout(:gzip => true)
    end
  end
end

