require 'hashie'
require 'data_mapper'

module Tent
  class Status
    class User
      include DataMapper::Resource

      storage_names[:default] = 'users'

      property :id, Serial
      property :entity, URI
      property :app_id, String
      property :app_mac, Json, :default => {}, :lazy => false
      property :profile, Json, :default => {}
      property :mac_key_id, String
      property :mac_key, String
      property :mac_algorithm, String
      property :profile_info_types, Json, :default => []
      property :post_types, Json, :default => []

      def self.find_or_create_from_auth_hash(auth_hash)
        user = first(:entity => auth_hash.uid)
        return user if user

        app = auth_hash.extra.raw_info.app
        app_auth = auth_hash.extra.raw_info.app_authorization
        credentials = auth_hash.extra.credentials
        p ['find_or_create_from_auth_hash', app_auth, credentials]
        create(
          :entity => auth_hash.uid,
          :app_id => app.id,
          :app_mac => {
            'mac_key_id' => app.mac_key_id,
            'mac_key' => app.mac_key,
            'mac_algorithm' => app.mac_algorithm
          },
          :profile => auth_hash.extra.raw_info.profile,
          :mac_key_id => app_auth.access_token,
          :mac_key => app_auth.mac_key,
          :mac_algorithm => app_auth.mac_algorithm,
          :profile_info_types => app_auth.profile_info_types,
          :post_types => app_auth.post_types
        )
      end

      def self.app_created_for_entity(app, entity)
        return unless user = first(:entity => entity)
        user.destroy
      end

      def self.get_app_from_entity(entity)
        return unless user = first(:entity => entity)
        Hashie::Mash.new(
          :id => user.app_id,
          :mac_key_id => user.app_mac['mac_key_id'],
          :mac_key => user.app_mac['mac_key'],
          :mac_algorithm => user.app_mac['mac_algorithm']
        )
      end

      def primary_server
        (core_profile['servers'] || []).first
      end

      def auth_details
        {
          :mac_key_id => mac_key_id,
          :mac_key => mac_key,
          :mac_algorithm => mac_algorithm
        }
      end

      def basic_profile
        (profile || {})['https://tent.io/types/info/basic/v0.1.0'] || {}
      end

      def core_profile
        (profile || {})['https://tent.io/types/info/core/v0.1.0'] || {}
      end
    end
  end
end

DataMapper.setup(:default, ENV['DATABASE_URL'])
DataMapper.auto_upgrade!

