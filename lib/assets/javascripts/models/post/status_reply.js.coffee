TentStatus.Models.StatusReplyPost = class StatusPostReplyModel extends TentStatus.Models.Post
  @model_name: 'status_reply_post'
  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.STATUS_REPLY)

