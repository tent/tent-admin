require "tent-admin/version"

module TentAdmin
  require 'tent-client/tent_type'
  TentType = TentClient::TentType

  require 'tent-admin/utils'
  require 'tent-admin/app'
  require 'tent-admin/model'

  def self.new(options = {}, &block)
    Model.new(options, &block)
    App.new(options, &block)
  end
end
