require 'sinatra/base'
require 'sprockets'
require 'uglifier'
require 'tent-client'
require 'rack/csrf'
require 'hashie'
require 'uri'
require 'sass'
require 'hogan_assets'

module Tent
  class Status < Sinatra::Base
    require 'tent-status/sprockets/environment'

    def initialize(app=nil, options = {})
      super(app)
      self.class.set :app_name, (options[:app_name] || ENV['APP_NAME'])
      self.class.set :app_icon, (options[:app_icon] || ENV['APP_ICON'])
      self.class.set :app_url, (options[:app_url] || ENV['APP_URL'])
      self.class.set :app_description, (options[:app_description] || ENV['APP_DESCRIPTION'])
      self.class.set :primary_entity, (options[:primary_entity] || ENV['PRIMARY_ENTITY'])
    end

    configure do
      set :assets, SprocketsEnvironment.assets
      set :cdn_url, false
      set :asset_manifest, false
      set :views, File.expand_path(File.join(File.dirname(__FILE__), 'views'))
    end

    configure :production do
      set :asset_manifest, Yajl::Parser.parse(File.read(ENV['STATUS_ASSET_MANIFEST'])) if ENV['STATUS_ASSET_MANIFEST']
      if ENV['STATUS_CDN_URL']
        set :cdn_url, ENV['STATUS_CDN_URL']
      end
    end

    if ENV['TENT_HOST_DOMAIN']
      helpers do
        def username_entity
          return unless (current_user || guest_user)
          (current_user || guest_user).username_entity
        end

        def tent_api_root
          return domain_tent_api_root unless username_entity
          username_entity + '/tent'
        end

        def full_url(path)
          if guest_user
            prefix = guest_user.username_entity
          else
            prefix = self_url_root
          end
          (prefix + full_path(path))
        end

        def auth_details
          auth = env['tent.app_auth'] || env['tent.guest_app_auth']
          return unless auth
          auth.auth_details
        end

        def current_user
          return unless defined?(TentD)
          current = TentD::Model::User.current
          return unless current
          return if current.id.nil?
          current if session[:current_user_id] == current.id
        end

        def guest_user
          return unless defined?(TentD)
          return unless session[:current_user_id]
          user = @guest_user ||= TentD::Model::User.first(:id => session[:current_user_id])
          current = TentD::Model::User.current
          return unless current
          return if session[:current_user_id] == current.id
          user if user && (session[:current_user_id] == user.id)
        end

        def custom_background_image
          user = current_user || guest_user
          return unless user

          profile_info = user.profile_infos_dataset.first(:type_base => 'https://tent.io/types/info/tent-status')

          return unless profile_info && profile_info.content.kind_of?(Hash)

          image_url = profile_info.content['background_image_url']
          return if !image_url || image_url.to_s =~ /\A[\s\r\t]*\Z/
          image_url
        end

        def current_entity
          return unless user = (current_user || guest_user)
          user.entity
        end

        def domain_entity
          return self_url_root unless user = TentD::Model::User.first(:id => env['user_id'])
          user.entity
        end

        def domain_tent_api_root
          return (self_url_root + '/tent') unless user = TentD::Model::User.first(:id => env['user_id'])
          user.username_entity + '/tent'
        end

        def app_api_root
          self_url_root + full_path('/api')
        end

        def in_application?
          true
        end

        def get_real_post_ids!(params)
          id_mapping = %w( post_id since_id before_id ).select { |key| params.has_key?(key) }.inject({}) { |memo, key|
            memo[params[key]] = key
            params[key] = nil
            memo
          }

          posts = TentD::Model::Post.select(:id, :public_id, :entity).where(:public_id => id_mapping.keys).all
          id_mapping.each_pair do |public_id, key|
            entity = params["#{key}_entity"]
            params[key] = posts.find { |p|
              p.public_id == public_id && (!entity || p.entity == entity)
            }
            params[key] = params[key].id if params[key]
          end
        end

        def post_dataset(params)
          dataset = TentD::Model::Post.where(
            :type_base => %w( https://tent.io/types/post/status ),
            :original => true,
            :public => true
          )

          dataset = dataset.where(:id => params['post_id']) if params['post_id']

          dataset = dataset.where { id > params['since_id'] } if params['since_id']
          dataset = dataset.where { id < params['before_id'] } if params['before_id']

          dataset = dataset.where(:entity => params['entity']) if params['entity']

          dataset = dataset.order(:published_at.desc)

          if params['mentioned_post'] || params['mentioned_entity']
            dataset = dataset.qualify.join(:mentions, :mentions__post_id => :posts__id).where(:mentions__original_post => true)
            dataset = dataset.where(:mentions__mentioned_post_id => params['mentioned_post']) if params['mentioned_post']
            dataset = dataset.where(:mentions__entity => params['mentioned_entity']) if params['mentioned_entity']
          end

          dataset = dataset.limit([TentD::API::MAX_PER_PAGE, (params[:limit] ? params[:limit].to_i : TentD::API::PER_PAGE)].min)

          dataset
        end
      end

      get '/api/posts' do
        get_real_post_ids!(params)
        dataset = post_dataset(params)

        posts = dataset.all

        json posts
      end

      get '/api/posts/:post_id' do
        get_real_post_ids!(params)
        dataset = post_dataset(params)

        post = dataset.first

        halt 404 unless post

        json post
      end

      get '/' do
        if env['tent.entity']
          erb :application
        else
          status 404
          erb :application
        end
      end
    else
      require 'tent-status/models/user'
      require 'omniauth-tent'
      require 'json'

      use OmniAuth::Builder do
        provider :tent,
          :get_app => lambda { |entity| User.get_app_from_entity(entity) },
          :on_app_created => lambda { |app, entity| User.app_created_for_entity(app, entity) },
          :app => {
            :name => Tent::Status.settings.app_name || '',
            :icon => Tent::Status.settings.app_icon || '',
            :url =>  Tent::Status.settings.app_url || 'http://localhost:9292',
            :description => Tent::Status.settings.app_description || 'Manage status posts, followers, and followings',
            :scopes => {
              "read_posts" => "See status posts",
              "write_posts" => "Create status posts",
              "read_profile" => "Show your basic profile",
              "write_profile" => "Save app specific data",
              "read_followings" => "See who you are following",
              "write_followings" => "Follow new entities",
              "read_followers" => "See who is following you",
              "write_followers" => "Block followers from receiving notifications",
              "read_groups" => "Add group to post permissions",
              "write_groups" => "Add new group to post permissions",
              "read_permissions" => "Display who can see a post"
            }
          },
          :post_types => %w( https://tent.io/types/post/status/v0.1.0 https://tent.io/types/post/repost/v0.1.0 ),
          :profile_info_types => %w( https://tent.io/types/info/tent-status/v0.1.0 )
      end

      get '/auth' do
        erb :auth, :layout => :application
      end

      get '/auth/tent/callback' do
        user = User.find_or_create_from_auth_hash(env['omniauth.auth'])
        session['current_user'] = user.id
        redirect '/'
      end

      get '/auth/failure' do
        redirect '/auth/tent'
      end

      get '/' do
        erb :application
      end

      helpers do
        def tent_api_root
          return domain_tent_api_root unless current_user
          current_user.primary_server
        end

        def app_api_root
        end

        def full_url(path)
          prefix = self_url_root
          (prefix + full_path(path))
        end

        def auth_details
          return unless current_user
          current_user.auth_details
        end

        def primary_user
          return unless settings.primary_entity
          User.first(:entity => settings.primary_entity)
        end

        def current_user
          return unless session['current_user']
          @current_user ||= User.first(:id => session['current_user'])
        end

        def guest_user
        end

        def username_entity
        end

        def current_entity
          return unless current_user
          current_user.entity
        end

        def domain_entity
          return unless primary_user || current_user
          (primary_user || current_user).entity
        end

        def domain_tent_api_root
          return unless primary_user || current_user
          (primary_user || current_user).primary_server
        end

        def in_application?
          env['PATH_INFO'] !~ %r{^(/setup)|(/assets)|(/auth)}
        end

        def custom_background_image
        end
      end

      before do
        if !(current_user || primary_user) && env['PATH_INFO'] !~ %r{^(/auth)|(/assets)|(/auth/tent)}
          halt redirect '/auth'
        end
      end
    end

    helpers do
      def user_brand
        return unless current_entity
        current_entity.to_s.sub(%r{\Ahttps?://([^/]+).*?\z}) { |m| $1 }
      end

      def tent_host_domain
        ENV['TENT_HOST_DOMAIN']
      end

      def tent_proxy_root
        self_url_root + '/tent-proxy'
      end

      def app_title
        settings.app_name
      end

      def path_prefix
        env['SCRIPT_NAME']
      end

      def asset_path(path)
        path = asset_manifest_path(path) || settings.assets.find_asset(path).digest_path
        if settings.cdn_url?
          "#{settings.cdn_url}/assets/#{path}"
        else
          full_path("/assets/#{path}")
        end
      end

      def asset_manifest_path(asset)
        if settings.asset_manifest?
          settings.asset_manifest['files'].detect { |k,v| v['logical_path'] == asset }[0]
        end
      end

      def full_path(path)
        "#{path_prefix}/#{path}".gsub(%r{//}, '/')
      end

      def self_port
        port = env.find { |k,v| k =~ /port/i }
        port = port.last.to_i if port
        port
      end

      def self_url_root
        url = (env['HTTP_X_FORWARDED_PROTO'] || env['rack.url_scheme']) + "://" + env['HTTP_HOST']
        if (port = self_port) && url !~ /:\d+\Z/
          url += ":#{port}"
        end
        url
      end

      def nav_selected_class(path)
        return '' if guest_user && !(env['PATH_INFO'] == '/global' && env['HTTP_HOST'] =~ %r{^app\.})
        env['PATH_INFO'] == path ? 'active' : ''
      end

      def discover(entity)
        client = ::TentClient.new
        entity = URI.decode_www_form_component(entity)
        client.discover(entity).get_profile
      rescue Faraday::Error::ConnectionFailed
        []
      end
    end

    def json(data)
      [200, { 'Content-Type' => 'application/json' }, [data.to_json]]
    end

    if ENV['RACK_ENV'] != 'production' || !ENV['STATUS_CDN_URL']
      get '/assets/*' do
        asset = params[:splat].first
        path = "./public/assets/#{asset}"
        if File.exists?(path)
          content_type = case asset.split('.').last
                         when 'css'
                           'text/css'
                         when 'js'
                           'application/javascript'
                         end
          headers = { 'Content-Type' => content_type } if content_type
          [200, headers, [File.read(path)]]
        else
          new_env = env.clone
          new_env["PATH_INFO"].gsub!("/assets", "")
          settings.assets.call(new_env)
        end
      end
    end

    get '/signout' do
      session.clear
      redirect full_path('/')
    end

    get '/favicon.ico' do
      halt 404
    end

    get '/tent-proxy/:proxy_entity/profile' do
      profile, server_url = discover(params[:proxy_entity])
      if server_url
        session["#{params[:proxy_entity]}-server_url"] = server_url
      end

      if profile
        json profile
      else
        status 404
      end
    end

    get '/tent-proxy/:proxy_entity/*' do
      entity = params.delete('proxy_entity')

      if entity == current_entity
        server_url = tent_api_root
        client = ::TentClient.new(server_url, auth_details)
      else
        unless server_url = session["#{entity}-server_url"]
          server_url = discover(entity).last
          halt 404 unless server_url
          session["#{entity}-server_url"] = server_url
        end
        client = ::TentClient.new(server_url)
      end

      begin
        path = env['PATH_INFO'].sub(%r{\A/tent-proxy/[^/]+/}, '')
        query_string = env['QUERY_STRING']
        path << "?#{query_string}" unless query_string.to_s == ""
        res = client.http.get(path)
      rescue Faraday::Error::ConnectionFailed
        halt 404
      end

      if res
        if res.success?
          json res.body
        else
          status res.status
        end
      else
        status 404
      end
    end

    get '/iframe-cache' do
      headers 'X-FRAME-OPTIONS' => "ALLOW-FROM #{env['HTTP_HOST'].sub(/^[^.]+\./, '')}"
      erb :iframe_cache
    end

    get '*' do
      erb :application
    end
  end
end
