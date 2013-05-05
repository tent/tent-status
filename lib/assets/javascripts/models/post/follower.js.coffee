TentStatus.Models.Follower = class FollowerModel extends TentStatus.Models.Post
  @model_name: 'follower'
  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.FOLLOWER)

