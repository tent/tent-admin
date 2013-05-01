require 'sequel-json'
require 'tent-client'

module TentAdmin
  module Model

    unless Model.db.table_exists?(:users)
      Model.db.create_table(:users) do
        primary_key :id
        column :entity, 'text', :null => false
        column :app, 'text', :null => false
        column :auth, 'text'
      end
    end

    class User < Sequel::Model(Model.db[:users])
      plugin :serialization
      serialize_attributes :json, :app, :auth

      def self.lookup(entity)
        first(:entity => entity)
      end

      def self.create(entity, app)
        if user = first(:entity => entity)
          user.update(:app => app)
        else
          user = super(:entity => entity, :app => app)
          user.setup_oauth!
        end
        user
      end

      def update_authorization(credentials)
        self.update(:auth => {
          :id => credentials[:id],
          :hawk_key => credentials[:hawk_key],
          :hawk_algorithm => credentials[:hawk_algorithm]
        })
        self.auth
      end

      def app_client
        @app_client ||= ::TentClient.new(entity, :credentials => Utils::Hash.symbolize_keys(app['credentials'].merge(:id => app['credentials']['hawk_id'])))
      end

      def client
        @client ||= ::TentClient.new(entity, :credentials => Utils::Hash.symbolize_keys(auth))
      end

      def app_exists?
        res = app_client.post.get(app['entity'], app['id'])
        res.success?
      end

      def server_meta_post
        @server_meta_post ||= begin
          post = client.server_meta_post
          if post && post['content']['entity'] != entity
            self.update(:entity => post['content']['entity'])
          end
          post
        end
      end

      ##
      # Update meta post to use this app for oauth
      def setup_oauth!
        data = Utils::Hash.symbolize_keys(server_meta_post)
        data[:content][:servers].each do |server|
          server[:urls][:oauth_auth] = "#{ENV['URL'].sub(%r{/\Z}, '')}/oauth"
        end
        data[:version] = { :parents => [{ :version => data[:version][:id] }] }
        res = client.post.update(data[:entity], data[:id], data)
        if res.success?
          @server_meta_post = client.server_meta_post = res.body
        end
        res
      end
    end

  end
end
