TentStatus.Collections.Posts = class PostsCollection extends TentStatus.Collection
  @model: TentStatus.Models.Post
  @params: {
    post_types: TentStatus.config.post_types
    limit: TentStatus.config.PER_PAGE
  }
