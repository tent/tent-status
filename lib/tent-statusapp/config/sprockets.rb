module SprocketsHelpers
  def asset_path(source, options = {})
    "/assets/#{environment.find_asset(source).digest_path}"
  end
end
