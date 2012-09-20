class TentStatus.Collections.Groups extends Backbone.Collection
  model: TentStatus.Models.Group
  url: "#{TentStatus.api_root}/groups"

TentStatus.Collections.groups = new TentStatus.Collections.Groups
