require 'tent-statusapp/sprockets/helpers'

module Tent
  class StatusApp
    module SprocketsEnvironment
      def assets
        return @assets if defined?(@assets)
        @assets = Sprockets::Environment.new do |env|
          env.logger = Logger.new(STDOUT)
          env.context_class.class_eval do
            include SprocketsHelpers
          end
        end
        @assets.register_engine('.slim', ::Slim::Template)

        paths = %w{ javascripts stylesheets images }
        paths.each do |path|
          @assets.append_path("assets/#{path}")
        end
        @assets
      end
    end
  end
end
