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
            :name             => TentStatus.settings[:name],
            :description      => TentStatus.settings[:description],
            :icon             => TentStatus.settings[:icon],
            :url              => TentStatus.settings[:url],
            :redirect_uri     => TentStatus.settings[:redirect_uri],
            :read_post_types  => TentStatus.settings[:read_post_types],
            :write_post_types => TentStatus.settings[:write_post_types],
            :scopes           => TentStatus.settings[:scopes]
          }
        }
      end
      b.use OmniAuthCallback
    end

    get '/signout' do |b|
      b.use Signout
    end

    get '/iframe-cache' do |b|
      b.use RenderView, :view => :iframe_cache
    end

    get '*' do |b|
      b.use Authentication
      b.use RenderView, :view => :application
    end

  end
end
