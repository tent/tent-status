TentStatus.Collections.Posts = class PostsCollection extends TentStatus.Collection
  @middleware: [
    new HTTP.Middleware.MacAuth(TentStatus.config.current_user.auth_details),
    new HTTP.Middleware.SerializeJSON
    new HTTP.Middleware.TentJSONHeader
  ]
  @model: TentStatus.Models.Post
  @url: TentStatus.config.tent_api_root + '/posts'
  @params: {
    post_types: TentStatus.config.post_types
    limit: TentStatus.config.PER_PAGE
  }
