require 'tent-status/version'
require 'yajl'

module TentStatus
  require 'tent-status/utils'

  def self.settings
    @settings ||= {
      :read_types => %w(),
      :write_types => %w(
        https://tent.io/types/status/v0
        https://tent.io/types/repost/v0
        https://tent.io/types/cursor/v0#https://tent.io/rels/status-mentions
        https://tent.io/types/cursor/v0#https://tent.io/rels/status-reposts
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
      :description   => settings[:description]   || ENV['APP_DESCRIPTION'],
      :display_url   => settings[:display_url]   || ENV['APP_DISPLAY_URL'],

      ##
      # App settings
      :url                  => settings[:url]                  || ENV['APP_URL'],
      :path_prefix          => settings[:path_prefix]          || ENV['PATH_PREFIX'],
      :asset_root           => settings[:asset_root]           || ENV['ASSET_ROOT'],
      :admin_url            => settings[:admin_url]            || ENV['ADMIN_URL'],
      :cdn_url              => settings[:cdn_url]              || ENV['APP_CDN_URL'],
      :database_url         => settings[:database_url]         || ENV['DATABASE_URL'],
      :database_logfile     => settings[:database_logfile]     || ENV['DATABASE_LOGFILE'] || STDOUT,
      :public_dir           => settings[:public_dir]           || File.expand_path('../../public/assets', __FILE__), # lib/../public/assets
      :json_config_url      => settings[:json_config_url]      || ENV['JSON_CONFIG_URL'],
      :signout_url          => settings[:signout_url]          || ENV['SIGNOUT_URL'],
      :signout_redirect_url => settings[:signout_redirect_url] || ENV['SIGNOUT_REDIRECT_URL'],
      :skip_authentication  => settings[:skip_authentication]  || ENV['SKIP_AUTHENTICATION'],

      ##
      # App service settings
      :search_api_root        => settings[:search_api_root]        || ENV['SEARCH_API_ROOT'],
      :search_api_key         => settings[:search_api_key]         || ENV['SEARCH_API_KEY'],
      :entity_search_api_root => settings[:entity_search_api_root] || ENV['ENTITY_SEARCH_API_ROOT'],
      :entity_search_api_key  => settings[:entity_search_api_key]  || ENV['ENTITY_SEARCH_API_KEY'],
      :site_feed_api_root     => settings[:site_feed_api_root]     || ENV['SITE_FEED_API_ROOT']
    )

    self.settings[:search_enabled] = self.settings[:search_api_root] && self.settings[:search_api_key]

    if ENV['APP_ASSET_MANIFEST'] && (_paths = ENV['APP_ASSET_MANIFEST'].to_s.split(',').select { |path| File.exists?(path) }) && _paths.any?
      self.settings[:asset_manifests] = _paths.map do |path|
        Yajl::Parser.parse(File.read(path))
      end
    end

    self.settings[:render_app_nav] = settings.has_key?(:render_app_nav) ? settings[:render_app_nav] : ENV['RENDER_APP_NAV'] != 'false'

    # App registration, oauth callback uri
    self.settings[:redirect_uri] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/auth/tent/callback"

    # App registration, display url
    self.settings[:display_url] ||= "https://github.com/tent/tent-status"

    # Default asset_root
    self.settings[:asset_root] ||= "/assets"

    # Default config.json url
    self.settings[:json_config_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/config.json"

    # Default signout url
    self.settings[:signout_url] ||= "#{self.settings[:url].to_s.sub(%r{/\Z}, '')}/signout"

    # Default signout redirect url
    self.settings[:signout_redirect_url] ||= self.settings[:url].to_s.sub(%r{/?\Z}, '/')
  end

  def self.new(settings = {})
    self.configure(settings)

    unless self.settings[:skip_authentication]
      require 'tent-status/model'
      Model.new(self.settings)
    end

    require 'tent-status/app'
    App.new
  end
end
