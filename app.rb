require 'sinatra/base'
require 'sprockets'
require 'tent-client'
require 'rack/csrf'
require 'hashie'
require 'uri'

class StatusPro < Sinatra::Base
  autoload :User, './models/user'

  configure :development do |config|
    require 'sinatra/reloader'
    register Sinatra::Reloader
    config.also_reload "*.rb"

    # Setup Database
    DataMapper.setup(:default, ENV['DATABASE_URL'])
    DataMapper.auto_upgrade!
  end

  use Rack::Session::Pool, :expire_after => 2592000, :key => 'tent-statuspro.session'
  use Rack::Csrf

  # List of paths/regexes not to require auth for
  public_routes = []

  helpers do
    def path_prefix
      env['SCRIPT_NAME']
    end

    def full_path(path)
      "/#{path}".gsub(%r{//}, '/')
    end

    def full_url(path)
      (self_url_root + path.gsub(%r{//}, '/'))
    end

    def self_url_root
      env['rack.url_scheme'] + "://" + env['HTTP_HOST']
    end

    def current_user
      return unless session[:current_user]
      @current_user ||= User.first(:entity => session[:current_user])
    end

    def csrf_tag
      Rack::Csrf.tag(env)
    end
  end

  assets = Sprockets::Environment.new do |env|
    env.logger = Logger.new(STDOUT)
  end

  %w{ javascripts stylesheets images }.each do |path|
    assets.append_path("assets/#{path}")
  end

  public_routes << %r{^/assets}
  get '/assets/*' do
    new_env = env.clone
    new_env["PATH_INFO"].gsub!("/assets", "")
    assets.call(new_env)
  end

  get '/' do
    slim :application
  end

  ########################
  #      OAuth stuff     #
  ########################

  before do
    if !session[:current_user] && !public_routes.find { |r|
        r.kind_of?(Regexp) ? !!r.match(env['PATH_INFO']) : r == env['PATH_INFO']
      }
      
      redirect full_path('/oauth')
      return false
    end
  end

  public_routes << '/oauth'
  get '/oauth' do
    slim :auth, :layout => :application
  end

  post '/oauth' do
    unless params[:entity]
      redirect full_path('/oauth') and return
    end

    client = ::TentClient.new
    profile, server_url = client.discover(params[:entity]).get_profile
    user = User.find_or_create(:entity => params[:entity], :profile => profile, :server_uri => server_url)

    data = {
      :name => 'Status Pro',
      :description => 'Manage your status posts',
      :icon => full_url('/assets/icon.png'),
      :redirect_uris => [full_url('/oauth/confirm')],
      :notification_url => full_url('/webhooks/notifications'),
      :scopes => {
        "read_posts"   => "Display posts feed",
        "write_posts"  => "Publish posts",
        "read_followers" => "List your followers",
        "write_followers" => "Manage your followers",
        "read_followings" => "List who you follow",
        "write_followings" => "Manage who you follow",
        "read_profile" => "Display your basic info"
      }
    }

    client = ::TentClient.new(server_url, Hashie::Mash.new(user.app_mac))
    unless (app = client.app.get(user.app_id).body) && !app.kind_of?(String)
      client = ::TentClient.new(server_url)
      data = Hashie::Mash.new(client.app.create(data).body)
      user.update(
        :app_id => data.id,
        :app_mac => {
          :mac_key_id => data.mac_key_id,
          :mac_key => data.mac_key,
          :mac_algorithm => data.mac_algorithm
        }
      )
    end

    auth_uri = URI(server_url + '/oauth')
    auth_uri.query = "client_id=#{user.app_id}"
    auth_uri.query += "&tent_profile_info_types=#{URI.encode_www_form_component(user.profile_info_types.join(','))}"
    auth_uri.query += "&tent_post_types=#{URI.encode_www_form_component(user.post_types.join(','))}"
    auth_uri.query += "&redirect_uri=#{URI.encode_www_form_component(full_url('/oauth/confirm'))}"
    auth_uri.query += "&tent_notification_url=#{URI.encode_www_form_component(data[:notification_url])}"
    auth_uri.query += "&state=#{session[:state] = SecureRandom.hex(32)}"

    session[:entity] = user.entity.to_s

    redirect auth_uri.to_s
  end

  public_routes << '/oauth/confirm'
  get '/oauth/confirm' do
    unless params[:state] == session.delete(:state) && session[:entity] && params[:code]
      redirect full_path("/oauth?error=#{params[:error]}") and return
    end

    user = User.first(:entity => session[:entity])

    client = ::TentClient.new(user.server_uri)
    mac = Hashie::Mash.new(client.app.authorization.create(user.app_id, :code => params[:code]).body)
    user.update(
      :mac_key_id => mac.access_token,
      :mac_key => mac.mac_key,
      :mac_algorithm => mac.mac_algorithm
    )

    session[:current_user] = user.entity

    redirect full_path('/')
  end

  get '/signout' do
    session.delete(:current_user)
    redirect full_path('/')
  end
end
