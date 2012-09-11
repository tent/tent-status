class StatusPro.Collections.Posts extends Backbone.Collection
  model: StatusPro.Models.Post
  url: "#{StatusPro.api_root}/posts"

StatusPro.Collections.posts = new StatusPro.Collections.Posts
