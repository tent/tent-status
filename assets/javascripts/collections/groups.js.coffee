class StatusApp.Collections.Groups extends Backbone.Collection
  model: StatusApp.Models.Group
  url: "#{StatusApp.api_root}/groups"

StatusApp.Collections.groups = new StatusApp.Collections.Groups
