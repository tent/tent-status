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

module Tent
  class StatusApp < Sinatra::Base
    require 'tent-statusapp/sprockets/environment'
    require 'tent-statusapp/models/user'

    configure :development do |config|
      require 'sinatra/reloader'
      register Sinatra::Reloader
      config.also_reload "*.rb"
    end

    use Rack::Csrf

    include SprocketsEnvironment

    helpers do
      def path_prefix
        env['SCRIPT_NAME']
      end

      def asset_path(path)
        path = assets.find_asset(path).digest_path
        if ENV['STATUS_CDN_URL']
          "#{ENV['STATUS_CDN_URL']}/assets/#{path}"
        else
          full_path("/assets/#{path}")
        end
      end

      def full_path(path)
        "#{path_prefix}/#{path}".gsub(%r{//}, '/')
      end

      def full_url(path)
        (self_url_root + full_path(path))
      end

      def self_url_root
        env['rack.url_scheme'] + "://" + env['HTTP_HOST']
      end

      def client
        env['tent.client']
      end

      def csrf_tag
        Rack::Csrf.tag(env)
      end

      def csrf_meta_tag(options = {})
        Rack::Csrf.metatag(env, options)
      end

      def basic_profile
        @basic_profile ||= (client.profile.get.body || {})['https://tent.io/types/info/basic/v0.1.0'] || {}
      end

      def current_user
        current = TentD::Model::User.current
        current if session[:current_user_id] == current.id
      end
    end

    def json(data)
      [200, { 'Content-Type' => 'application/json' }, [data.to_json]]
    end

    get '/assets/*' do
      new_env = env.clone
      new_env["PATH_INFO"].gsub!("/assets", "")
      assets.call(new_env)
    end

    get '/' do
      slim :application
    end

    get '/api/profile' do
      res = client.profile.get
      json res.body
    end

    get '/api/posts' do
      res = client.post.list params.merge(
        :types => ["https://tent.io/types/post/status/v0.1.0", "https://tent.io/types/post/repost/v0.1.0"]
      )

      if (400...500).include?(res.status)
        halt res.status
      end

      json res.body
    end

    get '/api/posts/:id' do
      res = client.post.get(params[:id])
      json res.body
    end

    post '/api/posts' do
      data = JSON.parse(env['rack.input'].read)
      env['rack.input'].rewind

      data = {
        :published_at => Time.now.to_i,
        :type => data['type'] || "https://tent.io/types/post/status/v0.1.0",
        :licenses => data['licenses'],
        :mentions => data['mentions'],
        :permissions => { public: true },
        :content => data['content'] || {
          :text => data['text'].to_s.slice(0...140)
        }
      }

      puts data.inspect

      res = client.post.create(data)

      json res.body
    end

    get '/api/groups' do
      res = client.group.list(params)
      json res.body
    end

    post '/api/groups' do
      data = JSON.parse(env['rack.input'].read)
      env['rack.input'].rewind

      res = client.group.create(data)
      json res.body
    end

    get '/api/followers' do
      res = client.follower.list(params)
      json res.body
    end

    put '/api/followers/:id' do
      data = JSON.parse(env['rack.input'].read)
      env['rack.input'].rewind

      res = client.follower.update(params[:id], data)
      json res.body
    end

    delete '/api/followers/:id' do
      res = client.follower.delete(params[:id])
      json res.body
    end

    get '/api/followings' do
      res = client.following.list(params)
      json res.body
    end

    post '/api/followings' do
      data = JSON.parse(env['rack.input'].read)
      env['rack.input'].rewind

      res = client.following.create(data['entity'])
      json res.body
    end

    put '/api/followings/:id' do
      data = JSON.parse(env['rack.input'].read)
      env['rack.input'].rewind

      res = client.following.update(params[:id], data)
      json res.body
    end

    delete '/api/followings/:id' do
      res = client.following.delete(params[:id])
      json res.body
    end

    get '/signout' do
      session.delete(:current_user)
      redirect full_path('/')
    end

    # Catch all for pushState routes
    get '*' do
      slim :application
    end
  end
end
