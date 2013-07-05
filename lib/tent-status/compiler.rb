require 'tent-status'

module TentStatus
  module Compiler
    extend self

    ASSET_NAMES = %w(
      icing.css
      application.css
      SourceSansPro-Bold-webfont.eot
      appicons.eot
      sourcesanspro-regular-webfont.eot
      SourceSansPro-Semibold-webfont.eot
      SourceSansPro-Regular-webfont.eot
      fontawesome-webfont.eot
      SourceSansPro-It-webfont.eot
      notifier.js
      iframe-cache.js
      application.js
      FontAwesome.otf
      repost.png
      edit.png
      reply.png
      site_feed.png
      search.png
      conversation.png
      timeline.png
      glyphicons-halflings-white.png
      gears.png
      glyphicons-halflings.png
      mentions.png
      profile.png
      SourceSansPro-Semibold-webfont.svg
      fontawesome-webfont.svg
      appicons.svg
      sourcesanspro-regular-webfont.svg
      SourceSansPro-Bold-webfont.svg
      SourceSansPro-It-webfont.svg
      SourceSansPro-Regular-webfont.svg
      SourceSansPro-Bold-webfont.ttf
      SourceSansPro-Regular-webfont.ttf
      fontawesome-webfont.ttf
      SourceSansPro-Semibold-webfont.ttf
      SourceSansPro-It-webfont.ttf
      sourcesanspro-regular-webfont.ttf
      appicons.ttf
      SourceSansPro-It-webfont.woff
      SourceSansPro-Bold-webfont.woff
      SourceSansPro-Regular-webfont.woff
      fontawesome-webfont.woff
      appicons.woff
      sourcesanspro-regular-webfont.woff
      SourceSansPro-Semibold-webfont.woff
    ).freeze

    attr_accessor :sprockets_environment, :assets_dir, :layout_dir

    def configure_app
      return if @app_configured

      # Load configuration
      TentStatus.configure

      @app_configured = true
    end

    def configure_sprockets
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

      # Setup asset compression
      require 'uglifier'
      require 'yui/compressor'
      sprockets_environment.js_compressor = Uglifier.new
      sprockets_environment.css_compressor = YUI::CssCompressor.new

      self.assets_dir ||= TentStatus.settings[:public_dir]

      @sprockets_configured = true
    end

    def configure_layout
      return if @layout_configured

      configure_sprockets

      self.layout_dir = File.expand_path(File.join(assets_dir, '..'))
      system  "mkdir -p #{layout_dir}"

      @layout_configured = true
    end

    def compile_assets
      configure_sprockets

      manifest = Sprockets::Manifest.new(
        sprockets_environment,
        assets_dir,
        File.join(assets_dir, "manifest.json")
      )

      manifest.compile(ASSET_NAMES)
    end

    def gzip_assets
      compile_assets

      Dir["#{assets_dir}/**/*.*"].reject { |f| f =~ /\.gz\z/ }.each do |f|
        system "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
      end
    end

    def compile_layout
      puts "Compiling layout..."

      configure_layout

      require 'tent-status/app'
      status, headers, body = TentStatus::App::RenderView.new(lambda {}).call(
        'response.view' => 'application'
      )

      output_path = File.join(layout_dir, 'index.html')
      system "rm #{output_path}" if File.exists?(output_path)
      File.open(output_path, "w") do |file|
        file.write(body.first)
      end

      puts "Layout compiled to #{output_path}"
    end
  end
end

