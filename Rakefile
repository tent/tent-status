require 'bundler/setup'
require './config/evergreen'
require './config/asset_sync'
require 'rake/sprocketstask'
require 'slim'
require 'hogan_assets'
require 'uglifier'

namespace :spec do
  desc "Run JavaScript specs via Evergreen"
  task :javascripts do
    result = Evergreen::Runner.new.run
    Kernel.exit(1) unless result
  end
end

Rake::SprocketsTask.new do |t|
  t.environment = Sprockets::Environment.new
  %w{ javascripts stylesheets images }.each do |path|
    t.environment.append_path("assets/#{path}")
  end
  t.environment.js_compressor = Uglifier.new
  t.environment.register_engine('.slim', ::Slim::Template)
  t.output      = "./public/assets"
  t.assets      = %w( boot.js application.css chosen-sprite.png )
end

task :deploy_assets => :assets do
  AssetSync.sync
end
