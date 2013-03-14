require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/sprocketstask'
require 'tent-status/sprockets/helpers'
require 'slim'
require 'hogan_assets'
require 'uglifier'
require 'yui/compressor'
require 'marbles-js'
require 'sprockets-sass'
require 'compass'

namespace :assets do
  Rake::SprocketsTask.new do |t|
    %x{rm -rf ./public}
    t.environment = Sprockets::Environment.new
    %w{ javascripts stylesheets images fonts }.each do |path|
      t.environment.append_path("assets/#{path}")
    end
    MarblesJS.sprockets_setup(t.environment)
    t.environment.js_compressor = Uglifier.new
    t.environment.css_compressor = YUI::CssCompressor.new
    t.output      = "./public/assets"
    t.assets      = %w( application.css SourceSansPro-Bold-webfont.eot appicons.eot sourcesanspro-regular-webfont.eot SourceSansPro-Semibold-webfont.eot SourceSansPro-Regular-webfont.eot fontawesome-webfont.eot SourceSansPro-It-webfont.eot notifier.js iframe-cache.js application.js FontAwesome.otf repost.png edit.png reply.png site_feed.png search.png conversation.png timeline.png glyphicons-halflings-white.png gears.png glyphicons-halflings.png mentions.png profile.png SourceSansPro-Semibold-webfont.svg fontawesome-webfont.svg appicons.svg sourcesanspro-regular-webfont.svg SourceSansPro-Bold-webfont.svg SourceSansPro-It-webfont.svg SourceSansPro-Regular-webfont.svg SourceSansPro-Bold-webfont.ttf SourceSansPro-Regular-webfont.ttf fontawesome-webfont.ttf SourceSansPro-Semibold-webfont.ttf SourceSansPro-It-webfont.ttf sourcesanspro-regular-webfont.ttf appicons.ttf SourceSansPro-It-webfont.woff SourceSansPro-Bold-webfont.woff SourceSansPro-Regular-webfont.woff fontawesome-webfont.woff appicons.woff sourcesanspro-regular-webfont.woff SourceSansPro-Semibold-webfont.woff )
    t.manifest = lambda { Sprockets::Manifest.new(t.environment, "./public/assets", "./public/assets/manifest.json") }

    t.environment.context_class.class_eval do
      include SprocketsHelpers
    end
  end

  task :gzip_assets => :assets do
    Dir['public/assets/**/*.*'].reject { |f| f =~ /\.gz\z/ }.each do |f|
      sh "gzip -c #{f} > #{f}.gz" unless File.exist?("#{f}.gz")
    end
  end

  task :deploy_assets => :gzip_assets do
    if ENV['S3_BUCKET'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      require './config/asset_sync'
      AssetSync.sync
    end
  end

  # deploy assets when deploying to heroku
  task :precompile => :deploy_assets
end
