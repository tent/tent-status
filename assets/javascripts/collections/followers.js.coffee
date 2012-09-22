class TentStatus.Collections.Followers extends Backbone.Collection
  model: TentStatus.Models.Follower
  url: ""

TentStatus.Collections.followers = new TentStatus.Collections.Followers
