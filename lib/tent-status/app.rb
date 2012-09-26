require 'sinatra/base'
require 'data_mapper'
require 'sprockets'
require 'uglifier'
require 'tent-client'
require 'rack/csrf'
require 'hashie'
require 'uri'
require 'slim'
require 'hogan_assets'
require 'oj'

module Tent
  class Status < Sinatra::Base
    require 'tent-status/sprockets/environment'
    require 'tent-status/models/user'

    configure do
      set :assets, SprocketsEnvironment.assets
      set :cdn_url, false
      set :asset_manifest, false
    end

    configure :production do
      set :asset_manifest, Oj.load(File.read(ENV['STATUS_ASSET_MANIFEST'])) if ENV['STATUS_ASSET_MANIFEST']
      set :cdn_url, ENV['STATUS_CDN_URL']
    end

    use Rack::Csrf

    helpers do
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

      def tent_api_root
        domain_entity + '/tent'
      end

      def full_url(path)
        if guest_user
          prefix = guest_user.entity
        else
          prefix = self_url_root
        end
        (prefix + full_path(path))
      end

      def self_url_root
        env['rack.url_scheme'] + "://" + env['HTTP_HOST']
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
        env['rack.url_scheme'] + '://' + env['HTTP_HOST']
      end

      def tent_host_domain
        ENV['TENT_HOST_DOMAIN']
      end
    end

    def json(data)
      [200, { 'Content-Type' => 'application/json' }, [data.to_json]]
    end

    if ENV['RACK_ENV'] != 'production'
      get '/assets/*' do
        new_env = env.clone
        new_env["PATH_INFO"].gsub!("/assets", "")
        settings.assets.call(new_env)
      end
    end

    get '/api/posts' do
      conditions = {}

      id_mapping = [:post_id, :since_id, :before_id].map(&:to_s).select { |key| params.has_key?(key) }.inject({}) { |memo, key|
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
      conditions[:id.gt] = params['since_id'] if params['since_id']
      conditions[:id.lt] = params['before_id'] if params['before_id']

      conditions[:type_base] = %w(https://tent.io/types/post/status) 
      conditions[:original] = true
      conditions[:public] = true
      conditions[:order] = :id.desc
      conditions[:limit] = [TentD::API::MAX_PER_PAGE, params[:limit].to_i].min if params[:limit]
      conditions[:limit] ||= TentD::API::PER_PAGE

      posts = TentD::Model::Post.send(:with_exclusive_scope, :deleted_at => nil) do |q|
        TentD::Model::Post.all(conditions)
      end

      TentD::Model::PostVersion.send(:with_exclusive_scope, :deleted_at => nil) do |q|
        json posts
      end
    end

    get '/' do
      if env['tent.entity']
        slim :application
      else
        status 404
        slim :application
      end
    end

    get '/signout' do
      session.clear
      redirect full_path('/')
    end

    get '/favicon.ico' do
      halt 404
    end

    get '*' do
      slim :application
    end
  end
end
