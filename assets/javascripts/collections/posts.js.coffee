class TentStatus.Collections.Posts extends Backbone.Collection
  model: TentStatus.Models.Post
  url: "#{TentStatus.config.tent_api_root}/posts?post_types=#{_.map(TentStatus.config.post_types, (t) -> encodeURIComponent(t)).join('&')}"

TentStatus.Collections.posts = new TentStatus.Collections.Posts
