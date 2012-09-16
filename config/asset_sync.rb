require 'asset_sync'

AssetSync.configure do |config|
  config.fog_provider = 'AWS'
  config.fog_directory = ENV['S3_BUCKET']
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.prefix = "assets"
  config.public_path = Pathname("./public")
  config.gzip_compression = true
  config.always_upload = %w( manifest.json )
end
