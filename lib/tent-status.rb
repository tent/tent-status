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

  def self.configure(settings = {})
    self.settings.merge!(
      ##
      # App registration settings
      :name          => settings[:name]          || ENV['APP_NAME'],
      :icon_url_base => settings[:icon_url_base] || ENV['APP_ICON_URL_BASE'],
      :url           => settings[:url]           || ENV['APP_URL'],
      :description   => settings[:description]   || ENV['APP_DESCRIPTION'],

      ##
      # App settings
      :admin_url            => settings[:admin_url]            || ENV['ADMIN_URL'],
      :cdn_url              => settings[:cdn_url]              || ENV['APP_CDN_URL'],
      :asset_manifest       => settings[:asset_manifest]       || (Yajl::Parser.parse(File.read(ENV['APP_ASSET_MANIFEST'])) if ENV['APP_ASSET_MANIFEST']),
      :database_url         => settings[:database_url]         || ENV['DATABASE_URL'],
      :database_logfile     => settings[:database_logfile]     || ENV['DATABASE_LOGFILE'] || STDOUT,
      :public_dir           => settings[:public_dir]           || File.expand_path('../../public/assets', __FILE__), # lib/../public/assets
      :json_config_url      => settings[:json_config_url]      || ENV['JSON_CONFIG_URL'],
      :signout_url          => settings[:signout_url]          || ENV['SIGNOUT_URL'],
      :signout_redirect_url => settings[:signout_redirect_url] || ENV['SIGNOUT_REDIRECT_URL'],
      :default_avatar_url   => settings[:default_avatar_url]   || ENV['DEFAULT_AVATAR_URL'],

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

    # Default config.json url
    self.settings[:json_config_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/config.json"

    # Default signout url
    self.settings[:signout_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/signout"

    # Default signout redirect url
    self.settings[:signout_redirect_url] ||= self.settings[:url].to_s.sub(%r{/?\Z/, '/'})
  end

  def self.new(settings = {})
    self.configure(settings)

    require 'tent-status/app'
    require 'tent-status/model'

    Model.new(self.settings)
    App.new
  end
end
