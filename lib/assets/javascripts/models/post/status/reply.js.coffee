TentStatus.Models.StatusReplyPost = class StatusReplyPostModel extends TentStatus.Models.StatusPost
  @model_name: 'post'
  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.STATUS_REPLY)

