TentStatus.Models.Following = class FollowingModel extends TentStatus.Models.Post
  @model_name: 'following'

  @validate: (entity) ->
    null

  @create: (entity, options) ->
    options.error(error: "Not implemented")

    # TODO:
    # - create subscription mentioning entity for wildcard status type
    # - create subscription mentioning entity for status reposts
    #
    # - show "pending" placeholder in list
    # - poll until relationship# post exists
    # - if delivery failure post exists for relationship, show warning/error

    ##
    # Create subscription for status posts
    TentStatus.Models.Subscription.create({
      type: TentStatus.config.POST_TYPES.STATUS_SUBSCRIPTION
      content:
        type: TentStatus.config.POST_TYPES.WILDCARD_STATUS
      mentions: [{ entity: entity }]
      permissions:
        public: true
        entities: [entity]
    }, {
      success: (subscription) =>
        console.log('subscription created', subscription)

      failure: (res, xhr) =>
    })

    ##
    # Create subscription for reposts
    TentStatus.Models.Subscription.create({
      type: TentStatus.config.POST_TYPES.REPOST_SUBSCRIPTION
      content:
        type: TentStatus.config.POST_TYPES.REPOST
      mentions: [{ entity: entity }]
      permissions:
        public: true
        entities: [entity]
    }, {
      success: (subscription) =>
        console.log('subscription created', subscription)

      failure: (res, xhr) =>
    })

