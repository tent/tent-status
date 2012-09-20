class TentStatus.Collections.Followers extends Backbone.Collection
  model: TentStatus.Models.Follower
  url: "#{TentStatus.api_root}/followers"

TentStatus.Collections.followers = new TentStatus.Collections.Followers
