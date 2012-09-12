class StatusPro.Collections.Groups extends Backbone.Collection
  model: StatusPro.Models.Group
  url: "#{StatusPro.api_root}/groups"

StatusPro.Collections.groups = new StatusPro.Collections.Groups
