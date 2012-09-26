class TentStatus.Collections.Followings extends Backbone.Collection
  model: TentStatus.Models.Following
  url: "#{TentStatus.config.current_tent_api_root}/followings"

TentStatus.Collections.followings = new TentStatus.Collections.Followings
