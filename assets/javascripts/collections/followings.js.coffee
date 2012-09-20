class TentStatus.Collections.Followings extends Backbone.Collection
  model: TentStatus.Models.Following
  url: "#{TentStatus.api_root}/followings"

TentStatus.Collections.followings = new TentStatus.Collections.Followings
