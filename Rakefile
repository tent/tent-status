require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/sprocketstask'
require 'tent-status/sprockets/helpers'
require 'slim'
require 'hogan_assets'
require 'uglifier'
require 'yui/compressor'

namespace :assets do
  Rake::SprocketsTask.new do |t|
    %x{rm -rf ./public}
    t.environment = Sprockets::Environment.new
    %w{ javascripts stylesheets images }.each do |path|
      t.environment.append_path("assets/#{path}")
    end
    t.environment.js_compressor = Uglifier.new
    t.environment.css_compressor = YUI::CssCompressor.new
    t.output      = "./public/assets"
    t.assets      = %w( application.js iframe-cache.js notifier.js application.css chosen-sprite.png stream_sprites.png topbar_sprites.png stream_sprites@2x.png topbar_sprites@2x.png texture.png bodytexture.png )

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
