require 'sequel'

module TentAdmin
  module Model
    class << self
      attr_accessor :db
    end

    ConfigurationError = Class.new(StandardError)

    def self.new(options = {})
      options[:database_url] ||= TentAdmin.settings[:database_url]
      options[:database_logfile] ||= TentAdmin.settings[:database_logfile]

      unless options[:database_url]
        raise ConfigurationError.new("Missing database_url option, you need to set DATABASE_URL")
      end

      self.db ||= Sequel.connect(options[:database_url], :logger => Logger.new(options[:database_logfile]))

      require 'tent-admin/model/user'
    end
  end
end
