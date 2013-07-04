require 'yaml'
require 'mimetype_fu'
require 'sprockets'
require 'coffee_script'
require 'sass'
require 'lodash-assets'
require 'marbles-js'
require 'marbles-tent-client-js'
require 'icing'

module TentStatus
  class App
    class AssetServer < Middleware

      module SprocketsHelpers
        AssetNotFoundError = Class.new(StandardError)
        def asset_path(source, options = {})
          asset = environment.find_asset(source)
          raise AssetNotFoundError.new("#{source.inspect} does not exist within #{environment.paths.inspect}!") unless asset
          "./#{asset.digest_path}"
        end
      end

      DEFAULT_MIME = 'application/octet-stream'.freeze

      class << self
        attr_accessor :asset_roots, :logfile
      end

      def self.sprockets_environment
        @environment ||= begin
          environment = Sprockets::Environment.new do |env|
            env.logger = Logger.new(@logfile || STDOUT)
            env.context_class.class_eval do
              include SprocketsHelpers
            end
          end

          paths = %w[ javascripts stylesheets images fonts ]
          @asset_roots.each do |asset_root|
            paths.each do |path|
              full_path = File.join(asset_root, path)
              next unless File.exists?(full_path)
              environment.append_path(full_path)
            end
          end

          MarblesJS::Sprockets.setup(environment)
          MarblesTentClientJS::Sprockets.setup(environment)
          Icing::Sprockets.setup(environment)

          Sprockets::Sass.options[:load_paths] = environment.paths

          environment
        end
      end

      def initialize(app, options = {})
        super

        @public_dir = @options[:public_dir] || TentStatus.settings[:public_dir]
      end

      def action(env)
        asset_name = env['params'][:splat]
        compiled_path = File.join(@public_dir, asset_name)

        if File.exists?(compiled_path)
          [200, { 'Content-Type' => asset_mime_type(asset_name) }, [File.read(compiled_path)]]
        else
          new_env = env.clone
          new_env["PATH_INFO"] = env["REQUEST_PATH"].sub(%r{\A/assets}, '')
          sprockets_environment.call(new_env)
        end
      end

      private

      def sprockets_environment
        @sprockets_environment ||= self.class.sprockets_environment
      end

      def asset_manifest_path(asset_name)
        self.class.asset_manifest_path(asset_name)
      end

      def asset_mime_type(asset_name)
        mime = File.mime_type?(asset_name)
        mime == 'unknown/unknown' ? DEFAULT_MIME : mime
      end

    end
  end
end
