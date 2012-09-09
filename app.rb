require 'sinatra/base'
require 'sprockets'
require 'tent-client'
require 'rack/csrf'
require 'hashie'
require 'uri'

class StatusPro < Sinatra::Base
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
  end

  assets = Sprockets::Environment.new do |env|
    env.logger = Logger.new(STDOUT)
  end

  %w{ javascripts stylesheets images }.each do |path|
    assets.append_path("assets/#{path}")
  end

  get '/assets/*' do
    new_env = env.clone
    new_env["PATH_INFO"].gsub!("/assets", "")
    assets.call(new_env)
  end

  get '/' do
    slim :application
  end
end
