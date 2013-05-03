TentStatus.Collections.Followers = class FollowersCollection extends TentStatus.Collection
  @model: TentStatus.Models.Follower
  @params: {
    limit: TentStatus.config.PER_PAGE
  }
