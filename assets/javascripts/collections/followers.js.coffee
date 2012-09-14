class StatusApp.Collections.Followers extends Backbone.Collection
  model: StatusApp.Models.Follower
  url: "#{StatusApp.api_root}/followers"

StatusApp.Collections.followers = new StatusApp.Collections.Followers
