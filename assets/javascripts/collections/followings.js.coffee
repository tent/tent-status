class StatusApp.Collections.Followings extends Backbone.Collection
  model: StatusApp.Models.Following
  url: "#{StatusApp.api_root}/followings"

StatusApp.Collections.followings = new StatusApp.Collections.Followings
