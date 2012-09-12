class StatusPro.Collections.Followers extends Backbone.Collection
  model: StatusPro.Models.Follower
  url: "#{StatusPro.api_root}/followers"

StatusPro.Collections.followers = new StatusPro.Collections.Followers
