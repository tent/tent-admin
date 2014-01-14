require "tent-admin/version"

module TentAdmin
  require 'tent-client/tent_type'
  TentType = TentClient::TentType

  require 'tent-admin/utils'

  ConfigurationError = Class.new(StandardError)

  def self.settings
    @settings ||= {
      :read_types => %w(all),
      :write_types => %w(
        https://tent.io/types/app/v0
        https://tent.io/types/app-auth/v0
        https://tent.io/types/credentials/v0
        https://tent.io/types/meta/v0
        https://tent.io/types/basic-profile/v0
      ),
      :scopes => %w( permissions )
    }
  end

  def self.configure(options = {})
    ##
    # App registration settings
    self.settings[:name]        = options[:name]        || ENV['APP_NAME']        || 'Admin'
    self.settings[:description] = options[:description] || ENV['APP_DESCRIPTION'] || 'Tent Server Admin App'
    self.settings[:display_url] = options[:display_url] || ENV['APP_DISPLAY_URL'] || 'https://github.com/tent/tent-admin'

    ##
    # App settings
    self.settings[:url]                  = options[:url]                  || ENV['URL']
    self.settings[:path_prefix]          = options[:path_prefix]          || ENV['PATH_PREFIX']
    self.settings[:public_dir]           = options[:public_dir]           || ENV['ASSETS_DIR'] || File.expand_path('../../public/assets', __FILE__) # lib/../public/assets
    self.settings[:database_url]         = options[:database_url]         || ENV['DATABASE_URL']
    self.settings[:database_logfile]     = options[:database_logfile]     || ENV['DATABASE_LOGFILE'] || STDOUT
    self.settings[:asset_root]           = options[:asset_root]           || ENV['ASSET_ROOT']
    self.settings[:asset_cache_dir]      = options[:asset_cache_dir]      || ENV['ASSET_CACHE_DIR']
    self.settings[:json_config_url]      = options[:json_config_url]      || ENV['JSON_CONFIG_URL']
    self.settings[:signout_url]          = options[:signout_url]          || ENV['SIGNOUT_URL']
    self.settings[:signout_redirect_url] = options[:signout_redirect_url] || ENV['SIGNOUT_REDIRECT_URL']
    self.settings[:signin_url]           = options[:signin_url]           || ENV['SIGNIN_URL']
    self.settings[:default_avatar_root]  = options[:default_avatar_root]  || ENV['DEFAULT_AVATAR_ROOT']

    unless settings[:url]
      raise ConfigurationError.new("Missing url option, you need to set URL")
    end

    self.settings[:asset_manifest] = Yajl::Parser.parse(File.read(ENV['APP_ASSET_MANIFEST'])) if ENV['APP_ASSET_MANIFEST'] && File.exists?(ENV['APP_ASSET_MANIFEST'])

    self.settings[:global_nav_config] ||= Yajl::Parser.parse(File.read(ENV['GLOBAL_NAV_CONFIG'])) if ENV['GLOBAL_NAV_CONFIG'] && File.exists?(ENV['GLOBAL_NAV_CONFIG'])

    if self.settings[:global_nav_config].nil?
      global_nav_items = [
        { "name" => "Admin", "url" => TentAdmin.settings[:url], "icon_class" => "app-icon-settings", "selected" => true }
      ]
      self.settings[:global_nav_config] = { 'items' => global_nav_items }
    end

    # bypass oauth when true
    self.settings[:skip_authentication] = (options[:skip_authentication] == true) || (ENV['SKIP_AUTHENTICATION'] == 'true')

    # App registration, oauth callback uri
    self.settings[:redirect_uri] = "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/auth/tent/callback"

    # Default asset root
    self.settings[:asset_root] ||= "/assets"

    # Default config.json url
    self.settings[:json_config_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/config.json"

    # Default signout url
    self.settings[:signout_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/signout"

    # Default signout redirect url
    self.settings[:signout_redirect_url] ||= self.settings[:url].to_s.sub(%r{/?\Z}, '/')
  end

  def self.new(options = {})
    self.configure(options)

    require 'tent-admin/app'

    unless self.settings[:skip_authentication]
      # We only need a database when authentication is enabled
      require 'tent-admin/model'
      Model.new
    end

    App.new
  end
end
