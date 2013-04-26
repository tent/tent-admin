require "tent-admin/version"

module TentAdmin
  require 'tent-admin/utils'
  require 'tent-admin/app'
  require 'tent-admin/model'

  def self.new(options = {}, &block)
    Model.new(options, &block)
    App.new(options, &block)
  end
end
