class StatusApp.Collections.Posts extends Backbone.Collection
  model: StatusApp.Models.Post
  url: "#{StatusApp.api_root}/posts"

StatusApp.Collections.posts = new StatusApp.Collections.Posts
