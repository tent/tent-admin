require "tent-admin/version"

module TentAdmin
  require 'tent-admin/app'

  def self.new(*args, &block)
    App.new(*args, &block)
  end
end
