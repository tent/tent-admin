require 'sequel'

module TentAdmin
  module Model
    class << self
      attr_accessor :db
    end

    def self.new(options = {})
      self.db ||= Sequel.connect(
        options[:database_url] || ENV['DATABASE_URL'],
        :logger => Logger.new(options[:database_logfile] || ENV['DATABASE_LOGFILE'] || STDOUT)
      )

      require 'tent-admin/model/user'
    end
  end
end
