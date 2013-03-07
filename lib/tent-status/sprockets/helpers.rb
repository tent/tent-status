module SprocketsHelpers
  AssetNotFoundError = Class.new(StandardError)
  def asset_path(source, options = {})
    asset = environment.find_asset(source)
    raise AssetNotFoundError.new("#{source.inspect} does not exist within #{environment.paths.inspect}!") unless asset
    "./#{asset.digest_path}"
  end
end
