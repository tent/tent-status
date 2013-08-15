require 'tent-status/compiler'

def configure_tent_status
  return if @tent_status_configured
  @tent_status_configured = true
  TentStatus.configure
end

namespace :icing do
  task :configure do
    configure_tent_status
    TentStatus::Compiler.compile_icing = true
  end
end

namespace :marbles do
  task :configure do
    configure_tent_status
    TentStatus::Compiler.compile_marbles = true
  end
end

namespace :assets do
  task :configure do
    configure_tent_status
  end

  task :compile => :configure do
    TentStatus::Compiler.compile_assets
  end

  task :gzip => :configure do
    TentStatus::Compiler.gzip_assets
  end

  task :deploy => :gzip do
    if ENV['S3_ASSETS'] == 'true' && ENV['S3_BUCKET'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'asset_sync'))
      AssetSync.sync
    end
  end

  # deploy assets when deploying to heroku
  task :precompile => ['icing:configure', 'marbles:configure', :deploy]
end
