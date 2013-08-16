TentStatus.Models.Follower = class FollowerModel extends TentStatus.Models.Post
  @model_name: 'follower'

  @fetchCount: (params, options = {}) ->
    params = _.extend(params, {
      types: TentStatus.config.subscriber_feed_types
    })

    super(params, options)

