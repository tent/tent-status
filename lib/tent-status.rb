require 'tent-status/version'

module TentStatus
  require 'tent-status/utils'

  def self.settings
    @settings ||= {
      :read_types => %w(
        https://tent.io/types/basic-profile/v0
        https://tent.io/types/status/v0
        https://tent.io/types/repost/v0
        https://tent.io/types/cursor/v0#https://tent.io/rels/status-mentions
        https://tent.io/types/cursor/v0#https://tent.io/rels/status-feed
        https://tent.io/types/subscription/v0
      ),
      :write_types => %w(
        https://tent.io/types/status/v0
        https://tent.io/types/repost/v0
        https://tent.io/types/cursor/v0#https://tent.io/rels/status-mentions
        https://tent.io/types/cursor/v0#https://tent.io/rels/status-feed
        https://tent.io/types/subscription/v0
      ),
      :scopes => %w()
    }
  end

  def self.new(settings = {})
    self.settings.merge!(
      ##
      # App registration settings
      :name        => settings[:name]        || ENV['TENT_STATUS_NAME'],
      :icon        => settings[:icon]        || ENV['TENT_STATUS_ICON'],
      :url         => settings[:url]         || ENV['TENT_STATUS_URL'],
      :description => settings[:description] || ENV['TENT_STATUS_DESCRIPTION'],

      ##
      # App settings
      :cdn_url          => settings[:cdn_url]          || ENV['TENT_STATUS_CDN_URL'],
      :asset_manifest   => settings[:asset_manifest]   || (Yajl::Parser.parse(File.read(ENV['TENT_STATUS_ASSET_MANIFEST'])) if ENV['TENT_STATUS_ASSET_MANIFEST']),
      :database_url     => settings[:database_url]     || ENV['DATABASE_URL'],
      :database_logfile => settings[:database_logfile] || ENV['DATABASE_LOGFILE'] || STDOUT,
      :public_dir       => settings[:public_dir]       || File.expand_path('../../public/assets', __FILE__), # lib/../public/assets
      :json_config_url  => settings[:json_config_url]  || ENV['JSON_CONFIG_URL'],

      ##
      # App service settings
      :avatar_proxy_host      => settings[:avatar_proxy_host]      || ENV['AVATAR_PROXY_HOST'],
      :search_api_root        => settings[:search_api_root]        || ENV['SEARCH_API_ROOT'],
      :search_api_key         => settings[:search_api_key]         || ENV['SEARCH_API_KEY'],
      :entity_search_api_root => settings[:entity_search_api_root] || ENV['ENTITY_SEARCH_API_ROOT'],
      :entity_search_api_key  => settings[:entity_search_api_key]  || ENV['ENTITY_SEARCH_API_KEY']
    )

    # App registration, oauth callback uri
    self.settings[:redirect_uri] ||= "#{self.settings[:url].sub(%r{/\Z}, '')}/auth/tent/callback"

    require 'tent-status/app'
    require 'tent-status/model'

    Model.new(self.settings)
    App.new
  end
end
