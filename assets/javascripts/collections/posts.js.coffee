class TentStatus.Collections.Posts extends Backbone.Collection
  model: TentStatus.Models.Post
  url: ""

TentStatus.Collections.posts = new TentStatus.Collections.Posts
