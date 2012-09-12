class StatusPro.Collections.Followings extends Backbone.Collection
  model: StatusPro.Models.Following
  url: "#{StatusPro.api_root}/followings"

StatusPro.Collections.followings = new StatusPro.Collections.Followings
