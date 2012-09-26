class TentStatus.Collections.Followers extends Backbone.Collection
  model: TentStatus.Models.Follower
  url: "#{TentStatus.config.current_tent_api_root}/followers"

TentStatus.Collections.followers = new TentStatus.Collections.Followers
