TentStatus.Collections.Followings = class FollowingsCollection extends TentStatus.Collection
  @middleware: [
    new HTTP.Middleware.MacAuth(TentStatus.config.current_user.auth_details),
    new HTTP.Middleware.SerializeJSON
    new HTTP.Middleware.TentJSONHeader
  ]
  @model: TentStatus.Models.Following
  @url: TentStatus.config.tent_api_root + '/followings'
  @params: {
    limit: TentStatus.config.PER_PAGE
  }
