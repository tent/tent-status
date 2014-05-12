require 'bundler'
Bundler.require

$stdout.sync = true

require './config'

require 'static-sprockets/app'

module StaticSprockets
  class App
    class ContentSecurityPolicy < Middleware
      def content_security_policy
        [
          "font-src data: 'self'",
          "frame-src #{ENV["CONTACTS_URL"].sub(/\A(https?:\/\/[^\/]+).*?\Z/, '\1')} 'self'",
          "script-src 'self'",
          "default-src 'self'",
          "object-src 'none'",
          "img-src *",
          "connect-src *"
        ].join('; ')
      end
    end
  end
end

map '/' do
  run StaticSprockets::App.new
end
