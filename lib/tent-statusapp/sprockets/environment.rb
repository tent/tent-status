require 'tent-status/sprockets/helpers'

module Tent
  class Status
    module SprocketsEnvironment
      def self.assets
        return @assets if defined?(@assets)
        puts 'SprocketsEnvironment loaded'
        @assets = Sprockets::Environment.new do |env|
          env.logger = Logger.new(STDOUT)
          env.context_class.class_eval do
            include SprocketsHelpers
          end
        end
        @assets.register_engine('.slim', ::Slim::Template)

        paths = %w{ javascripts stylesheets images }
        paths.each do |path|
          @assets.append_path(File.join(File.expand_path('../../../../', __FILE__), "assets/#{path}"))
        end
        @assets
      end
    end
  end
end
