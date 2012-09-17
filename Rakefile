require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/sprocketstask'
require 'tent-statusapp/sprockets/helpers'
require 'slim'
require 'hogan_assets'
require 'uglifier'

namespace :spec do
  desc "Run JavaScript specs via Evergreen"
  task :javascripts do
    require './config/evergreen'
    result = Evergreen::Runner.new.run
    Kernel.exit(1) unless result
  end
end

Rake::SprocketsTask.new do |t|
  %x{rm -rf ./public}
  t.environment = Sprockets::Environment.new
  %w{ javascripts stylesheets images }.each do |path|
    t.environment.append_path("assets/#{path}")
  end
  t.environment.js_compressor = Uglifier.new
  t.environment.register_engine('.slim', ::Slim::Template)
  t.output      = "./public/assets"
  t.assets      = %w( boot.js application.css chosen-sprite.png )

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
  require './config/asset_sync'
  AssetSync.sync
end
