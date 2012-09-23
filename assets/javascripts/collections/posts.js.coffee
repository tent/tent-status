class TentStatus.Collections.Posts extends Backbone.Collection
  model: TentStatus.Models.Post
  url: "#{TentStatus.config.tent_api_root}/posts"

TentStatus.Collections.posts = new TentStatus.Collections.Posts
