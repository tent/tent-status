require 'tent-status/compiler'

namespace :icing do
  require 'icing/tasks/assets'

  task :configure do
    TentStatus.configure
    Icing.settings[:public_dir] = TentStatus.settings[:public_dir]
  end
end

namespace :marbles do
  require 'marbles-js/tasks/assets'

  task :configure do
    TentStatus.configure
    MarblesJS.settings[:public_dir] = TentStatus.settings[:public_dir]
  end
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
  task :precompile => [:deploy, 'icing:configure', 'icing:assets:precompile', 'marbles:configure', 'marbles:assets:precompile']
end
