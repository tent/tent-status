class StatusPro
  class User
    include DataMapper::Resource

    property :entity, URI, :key => true
    property :server_uri, URI
    property :app_id, String
    property :app_mac, Json, :default => {}, :lazy => false
    property :profile, Json, :default => {}
    property :mac_key_id, String
    property :mac_key, String
    property :mac_algorithm, String
    property :profile_info_types, Json, :default => %w{ https://tent.io/types/info/basic/v0.1.0 }
    property :post_types, Json, :default => %w{ https://tent.io/types/post/status/v0.1.0 }

    def self.find_or_create(params)
      first(:entity => params[:entity]) || create(params)
    end

    def auth_details
      {
        :mac_key_id => mac_key_id,
        :mac_key => mac_key,
        :mac_algorithm => mac_algorithm
      }
    end
  end
end
