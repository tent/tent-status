require 'sequel-json'
require 'tent-client'

module TentStatus
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

      def json_config
        {
          :credentials => auth,
          :meta => server_meta_post
        }
      end
    end

  end
end
