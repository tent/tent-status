TentStatus.Models.StatusPost = class StatusPostModel extends TentStatus.Models.Post
  @model_name: 'status_post'
  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.STATUS)

  @validate: (attrs, options = {}) ->
    errors = []

    if (attrs.content?.text and attrs.content.text.match /^[\s\r\t]*$/) || (options.validate_empty and attrs.content?.text == "")
      errors.push { text: 'Status must not be empty' }

    # TODO: fix length calculation
    if attrs.content?.text and attrs.content.text.length > TentStatus.config.MAX_STATUS_LENGTH
      errors.push { text: "Status must be no more than #{TentStatus.config.MAX_STATUS_LENGTH} characters" }

    return errors if errors.length
    null

  fetchReplies: (options = {}) =>
    completeFn = (res, xhr) =>
      posts = null
      if xhr.status in [200, 304]
        posts = _.map(res.data, (data) =>
          post = TentStatus.Models.StatusReplyPost.find(entity: data.entity, id: data.id, fetch: false) || new TentStatus.Models.StatusReplyPost
          post.parseAttributes(data)
          post
        )
        options.success?(posts, xhr)
      else
        options.failure?(res, xhr)
      options.complete?(posts, res, xhr)

    TentStatus.tent_client.post.list(
      params:
        mentions: [@get('entity'), @get('id')].join('+')
        types: [TentStatus.config.POST_TYPES.STATUS_REPLY]
        limit: TentStatus.config.PER_CONVERSATION_PAGE
      callback: completeFn
    )

    null

