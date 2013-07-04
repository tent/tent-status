require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/sprocketstask'

namespace :assets do
  Rake::SprocketsTask.new(:compile) do |t|
    # Load configuration
    require 'tent-status'
    TentStatus.configure

    # Setup Sprockets Environment
    require 'rack-putty'
    require 'tent-status/app/middleware'
    require 'tent-status/app/asset_server'
    TentStatus::App::AssetServer.asset_roots = %w( lib/assets vendor/assets )
    TentStatus::App::AssetServer.logfile = '/dev/null'
    t.environment = TentStatus::App::AssetServer.sprockets_environment

    require 'uglifier'
    require 'yui/compressor'
    t.environment.js_compressor = Uglifier.new
    t.environment.css_compressor = YUI::CssCompressor.new

    t.manifest = lambda { Sprockets::Manifest.new(t.environment, "./public/assets", "./public/assets/manifest.json") }

    t.output = "./public/assets"
    t.assets = %w(
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
    )
  end

  task :gzip => :compile do
    Dir['public/assets/**/*.*'].reject { |f| f =~ /\.gz\z/ }.each do |f|
      sh "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
    end
  end

  task :deploy => :gzip do
    if ENV['S3_BUCKET'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      require './config/asset_sync'
      AssetSync.sync
    end
  end

  # deploy assets when deploying to heroku
  task :precompile => :deploy
end

namespace :layout do
  task :compile do
    puts "Compiling layout..."

    require 'tent-status'
    TentStatus.configure

    require 'tent-status/app'
    status, headers, body = TentStatus::App::RenderView.new(lambda {}).call(
      'response.view' => 'application'
    )

    require 'fileutils'
    output_dir = File.join(File.expand_path(File.dirname(__FILE__)), 'public')
    FileUtils.mkdir_p(output_dir)

    output_path = File.join(output_dir, 'index.html')
    FileUtils.rm(output_path) if File.exists?(output_path)
    File.open(output_path, "w") do |file|
      file.write(body.first)
    end

    puts "Layout compiled to #{output_path}"
  end

  task :gzip => :compile do
    require 'fileutils'
    Dir['public/index.html'].each do |f|
      path = "#{f}.gz"
      FileUtils.rm(path) if File.exists?(path)
      sh "gzip -c #{f} > #{path}"
    end
  end
end
