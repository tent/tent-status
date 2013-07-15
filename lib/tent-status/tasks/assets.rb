require 'tent-status/compiler'

TentStatus.configure

namespace :icing do
  require 'icing/tasks/assets'
  Icing.settings[:public_dir] = TentStatus.settings[:public_dir]
end

namespace :marbles do
  require 'marbles-js/tasks/assets'
  MarblesJS.settings[:public_dir] = TentStatus.settings[:public_dir]
end

namespace :assets do
  task :compile do
    TentStatus::Compiler.compile_assets
  end

  task :gzip do
    TentStatus::Compiler.gzip_assets
  end

  task :deploy => :gzip do
    if ENV['S3_ASSETS'] == 'true' && ENV['S3_BUCKET'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'asset_sync'))
      AssetSync.sync
    end
  end

  # deploy assets when deploying to heroku
  task :precompile => [:deploy, 'icing:assets:precompile', 'marbles:assets:precompile']
end
