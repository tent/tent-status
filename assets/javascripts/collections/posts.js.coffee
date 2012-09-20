class TentStatus.Collections.Posts extends Backbone.Collection
  model: TentStatus.Models.Post
  url: "#{TentStatus.api_root}/posts"

TentStatus.Collections.posts = new TentStatus.Collections.Posts
