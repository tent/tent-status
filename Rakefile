require 'bundler/setup'
require './config/evergreen'
require './config/asset_sync'

namespace :spec do
  desc "Run JavaScript specs via Evergreen"
  task :javascripts do
    result = Evergreen::Runner.new.run
    Kernel.exit(1) unless result
  end
end

namespace :assets do
  desc "Precompile assets"
  task :precompile do
    target = Pathname('./public/assets')
    manifest = Sprockets::Manifest.new(sprockets, "./public/assets/manifest.json")

    sprockets.each_logical_path do |logical_path|
      if (!File.extname(logical_path).in?(['.js', '.css']) || logical_path =~ /application\.(css|js)$/) && asset = sprockets.find_asset(logical_path)
        filename = target.join(logical_path)
        FileUtils.mkpath(filename.dirname)
        puts "Write asset: #{filename}"
        asset.write_to(filename)
        manifest.compile(logical_path)
      end
    end

    AssetSync.sync
  end
end
