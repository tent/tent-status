require 'tent-status'

module TentStatus
  module Compiler
    extend self

    ASSET_NAMES = %w(
      application.css
      application.js
      repost.png
      edit.png
      reply.png
      site_feed.png
      search.png
      conversation.png
      timeline.png
      gears.png
      mentions.png
      profile.png
    ).freeze

    attr_accessor :sprockets_environment, :assets_dir, :layout_dir, :layout_path, :layout_env

    def configure_app(options = {})
      return if @app_configured

      # Load configuration
      TentStatus.configure(options)

      @app_configured = true
    end

    def configure_sprockets(options = {})
      return if @sprockets_configured

      configure_app

      # Setup Sprockets Environment
      require 'rack-putty'
      require 'tent-status/app/middleware'
      require 'tent-status/app/asset_server'

      gem_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      TentStatus::App::AssetServer.asset_roots = %w( lib/assets vendor/assets ).map do |path|
        File.join(gem_root, path)
      end

      TentStatus::App::AssetServer.logfile = STDOUT

      self.sprockets_environment = TentStatus::App::AssetServer.sprockets_environment

      if options[:compress]
        # Setup asset compression
        require 'uglifier'
        require 'sprockets-rainpress'
        sprockets_environment.js_compressor = Uglifier.new
        sprockets_environment.css_compressor = Sprockets::Rainpress
      end

      self.assets_dir ||= TentStatus.settings[:public_dir]

      @sprockets_configured = true
    end

    def configure_layout
      return if @layout_configured

      configure_sprockets

      self.layout_dir ||= File.expand_path(File.join(assets_dir, '..'))
      self.layout_path ||= File.join(layout_dir, 'status.html')
      system  "mkdir -p #{layout_dir}"

      self.layout_env ||= {
        'response.view' => 'application'
      }

      @layout_configured = true
    end

    def compile_assets(options = {})
      configure_sprockets(options)

      manifest = Sprockets::Manifest.new(
        sprockets_environment,
        assets_dir,
        File.join(assets_dir, "manifest.json")
      )

      manifest.compile(ASSET_NAMES)
    end

    def compress_assets
      compile_assets(:compress => true)
    end

    def gzip_assets
      compress_assets

      Dir["#{assets_dir}/**/*.*"].reject { |f| f =~ /\.gz\z/ }.each do |f|
        system "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
      end
    end

    def compile_layout(options = {})
      puts "Compiling layout..."

      configure_layout

      require 'tent-status/app'
      status, headers, body = TentStatus::App::RenderView.new(lambda {}).call(layout_env)

      system "rm #{layout_path}" if File.exists?(layout_path)
      File.open(layout_path, "w") do |file|
        file.write(body.first)
      end

      if options[:gzip]
        system "gzip -c #{layout_path} > #{layout_path}.gz"
      end

      puts "Layout compiled to #{layout_path}"
    end

    def gzip_layout
      compile_layout(:gzip => true)
    end
  end
end

