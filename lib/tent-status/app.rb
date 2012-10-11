require 'sinatra/base'
require 'data_mapper'
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
        def tent_api_root
          return domain_tent_api_root unless (current_user || guest_user)
          (current_user || guest_user).entity + '/tent'
        end

        def full_url(path)
          if guest_user
            prefix = guest_user.entity
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
          user = @guest_user ||= TentD::Model::User.get(session[:current_user_id])
          current = TentD::Model::User.current
          return unless current
          return if session[:current_user_id] == current.id
          user if user && (session[:current_user_id] == user.id)
        end

        def domain_entity
          self_url_root
        end

        def domain_tent_api_root
          domain_entity + '/tent'
        end

        def app_api_root
          self_url_root + full_path('/api')
        end

        def in_application?
          true
        end

        def get_real_post_ids!(params)
          id_mapping = %w( post_id since_id before_id ).
            select { |key| params.has_key?(key) }.inject({}) { |memo, key|
              memo[params[key]] = key
              params[key] = nil
              memo
            }

          posts = TentD::Model::Post.send(:with_exclusive_scope, {}) { |q|
            TentD::Model::Post.all(:public_id => id_mapping.keys, :fields => [:id, :public_id, :entity]).to_a
          }
          id_mapping.each_pair do |public_id, key|
            entity = params["#{key}_entity"]
            params[key] = posts.find { |p|
              p.public_id == public_id && p.entity == entity
            }
            params[key] = params[key].id if params[key]
          end
        end

        def post_conditions(params)
          conditions = {}

          conditions[:id.gt] = params['since_id'] if params['since_id']
          conditions[:id.lt] = params['before_id'] if params['before_id']

          conditions[:entity] = params['entity'] if params['entity']

          if params['mentioned_post'] || params['mentioned_entity']
            conditions[:mentions] = { :original_post => true }
            conditions[:mentions][:mentioned_post_id] = params['mentioned_post'] if params['mentioned_post']
            conditions[:mentions][:entity] = params['mentioned_entity'] if params['mentioned_entity']
          end

          conditions[:type_base] = %w( https://tent.io/types/post/status )
          conditions[:original] = true
          conditions[:public] = true
          conditions[:order] = :published_at.desc
          conditions[:limit] = [TentD::API::MAX_PER_PAGE, params[:limit].to_i].min if params[:limit]
          conditions[:limit] ||= TentD::API::PER_PAGE

          conditions
        end

        def with_exclusive_scope(klass, scope={ :deleted_at => nil }, &block)
          klass.send(:with_exclusive_scope, scope) do |q|
            block.call
          end
        end
      end

      get '/api/posts' do
          get_real_post_ids!(params)
        conditions = post_conditions(params)

        posts = with_exclusive_scope(TentD::Model::Post) do
          TentD::Model::Post.all(conditions)
        end

        with_exclusive_scope(TentD::Model::PostVersion) do
          json posts
        end
      end

      get '/api/posts/:post_id' do
        get_real_post_ids!(params)
        conditions = post_conditions(params)
        conditions[:id] = params['post_id']

        post = with_exclusive_scope(TentD::Model::Post) do
          TentD::Model::Post.first(conditions)
        end

        halt 404 unless post

        with_exclusive_scope(TentD::Model::PostVersion) do
          json post
        end
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
              "read_followings" => "See who you are following",
              "write_followings" => "Follow new entities",
              "read_followers" => "See who is following you",
              "write_followers" => "Block followers from receiving notifications",
              "read_groups" => "Add group to post permissions",
              "write_groups" => "Add new group to post permissions"
            }
          },
          :post_types => %w( https://tent.io/types/post/status/v0.1.0 https://tent.io/types/post/repost/v0.1.0 ),
          :profile_info_types => %w( https://tent.io/types/info/basic/v0.1.0 https://tent.io/types/info/core/v0.1.0 )
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
          @current_user ||= User.get(session['current_user'])
        end

        def guest_user
        end

        def current_entity
          return unless current_user
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

      def current_entity
        return unless current_user || guest_user
        (current_user || guest_user).entity = (current_user || guest_user).entity
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
        url = env['rack.url_scheme'] + "://" + env['HTTP_HOST']
        if (port = self_port) && url !~ /:\d+\Z/
          url += ":#{port}"
        end
        url
      end

      def nav_selected_class(path)
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
        session["#{params[:entity]}-server_url"] = server_url
      end

      if profile
        json profile
      else
        status 404
      end
    end

    get '/tent-proxy/:proxy_entity/*' do
      entity = params.delete('proxy_entity')
      unless server_url = session["#{entity}-server_url"]
        server_url = discover(entity).last
        halt 404 unless server_url
        session["#{entity}-server_url"] = server_url
      end

      client = ::TentClient.new(server_url)
      begin
        res = case params.delete('splat').to_a.first
        when 'posts'
          client.post.list(params)
        when 'posts/count'
          client.post.count(params)
        when 'followers'
          client.follower.list(params)
        when 'followers/count'
          client.follower.count(params)
        when 'followings'
          client.following.list(params)
        when 'followings/count'
          client.following.count(params)
        end
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

    get '*' do
      erb :application
    end
  end
end
