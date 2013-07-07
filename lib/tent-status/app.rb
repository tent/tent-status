require 'rack-putty'
require 'omniauth-tent'

module TentStatus
  class App

    require 'tent-status/app/middleware'
    require 'tent-status/app/serialize_response'
    require 'tent-status/app/asset_server'
    require 'tent-status/app/render_view'
    require 'tent-status/app/authentication'

    AssetServer.asset_roots = [
      File.expand_path('../../assets', __FILE__), # lib/assets
      File.expand_path('../../../vendor/assets', __FILE__) # vendor/assets
    ]

    RenderView.view_roots = [
      File.expand_path(File.join(File.dirname(__FILE__), '..', 'views')) # lib/views
    ]

    include Rack::Putty::Router

    stack_base SerializeResponse

    class Favicon < Middleware
      def action(env)
        env['REQUEST_PATH'].sub!(%r{/favicon}, "/assets/favicon")
        env['params'][:splat] = 'favicon.ico'
        env
      end
    end

    class CacheControl < Middleware
      def action(env)
        env['response.headers'] ||= {}
        env['response.headers'].merge!(
          'Cache-Control' => @options[:value].to_s,
          'Vary' => 'Cookie'
        )
        env
      end
    end

    class AccessControl < Middleware
      def action(env)
        env['response.headers'] ||= {}
        if @options[:allow_credentials]
          env['response.headers']['Access-Control-Allow-Credentials'] = 'true'
        end
        env['response.headers'].merge!(
          'Access-Control-Allow-Origin' => 'self',
          'Access-Control-Allow-Methods' => 'DELETE, GET, HEAD, PATCH, POST, PUT',
          'Access-Control-Allow-Headers' => 'Cache-Control, Pragma',
          'Access-Control-Max-Age' => '10000'
        )
        env
      end
    end

    class ContentSecurityPolicy < Middleware
      def action(env)
        env['response.headers'] ||= {}
        env['response.headers']["Content-Security-Policy"] = content_security_policy
        env
      end

      def content_security_policy
        [
          "default-src 'self'",
          "object-src 'none'",
          "img-src *",
          "connect-src *"
        ].join('; ')
      end
    end

    get '/assets/*' do |b|
      b.use AssetServer
    end

    get '/favicon.ico' do |b|
      b.use Favicon
      b.use AssetServer
    end

    match %r{\A/auth/tent(/callback)?} do |b|
      b.use OmniAuth::Builder do
        provider :tent, {
          :get_app => AppLookup,
          :on_app_created => AppCreate,
          :app => {
            :name         => TentStatus.settings[:name],
            :description  => TentStatus.settings[:description],
            :icon         => TentStatus.settings[:icon],
            :url          => TentStatus.settings[:url],
            :redirect_uri => TentStatus.settings[:redirect_uri],
            :read_types   => TentStatus.settings[:read_types],
            :write_types  => TentStatus.settings[:write_types],
            :scopes       => TentStatus.settings[:scopes]
          }
        }
      end
      b.use OmniAuthCallback
    end

    post '/signout' do |b|
      b.use Signout
    end

    get '/iframe-cache' do |b|
      b.use RenderView, :view => :iframe_cache
    end

    get '/config.json' do |b|
      b.use AccessControl, :allow_credentials => true
      b.use CacheControl, :value => 'no-cache'
      b.use Authentication, :redirect => false
      b.use CacheControl, :value => 'private, max-age=600'
      b.use RenderView, :view => :'config.json', :content_type => "application/json"
    end

    get '*' do |b|
      b.use ContentSecurityPolicy
      b.use Authentication
      b.use RenderView, :view => :application
    end

  end
end
