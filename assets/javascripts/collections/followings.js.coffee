class TentStatus.Collections.Followings extends Backbone.Collection
  model: TentStatus.Models.Following
  url: ""

TentStatus.Collections.followings = new TentStatus.Collections.Followings
