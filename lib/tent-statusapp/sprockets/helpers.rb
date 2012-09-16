module SprocketsHelpers
  def asset_path(source, options = {})
    "./#{environment.find_asset(source).digest_path}"
  end
end
