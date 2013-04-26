require 'sequel-json'

module TentAdmin
  module Model

    class User < Sequel::Model(Model.db[:users])
      unless Model.db.table_exists?(:users)
        Model.db.create_table(:users) do
          primary_key :id
          column :entity, 'text', :null => false
          column :app, 'text', :null => false
        end
        User.columns # load columns
      end

      plugin :serialization
      serialize_attributes :json, :app

      def self.lookup(entity)
        first(:entity => entity)
      end

      def self.create(entity, app)
        super(:entity => entity, :app => app)
      end
    end

  end
end
