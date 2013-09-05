TentStatus.Models.StatusPost = class StatusPostModel extends TentStatus.Models.Post
  @model_name: 'post'
  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.STATUS)

  @validate: (attrs, options = {}) ->
    errors = []

    if (attrs.content?.text and attrs.content.text.match /^[\s\r\t]*$/) || (options.validate_empty and attrs.content?.text == "")
      errors.push { text: 'Status must not be empty' }

    if attrs.content?.text and TentStatus.Helpers.numChars(attrs.content.text) > TentStatus.config.MAX_STATUS_LENGTH
      errors.push { text: "Status must be no more than #{TentStatus.config.MAX_STATUS_LENGTH} characters" }

    return errors if errors.length
    null

  @fetchCount: (params, options = {}) ->
    params.types ?= [
      @post_type.toStringWithoutFragment()
    ]

    super(params, options)

  fetchReplies: (options = {}) =>
    num_pending_posts = 0
    models = {}
    mentions = []

    keyForMention = (mention) =>
      mention.entity + ' ' + mention.post

    fetchPostComplete = (mention, res, xhr) =>
      num_pending_posts -= 1

      if xhr.status == 200
        postConstructor = TentStatus.Models.Post.constructorForType(res.post.type)
        models[keyForMention(mention)] = new postConstructor(res.post)

      if num_pending_posts <= 0
        _models = []
        for mention in mentions
          _model = models[keyForMention(mention)]
          continue unless _model
          _models.push(_model)

        console.log 'fetchReplies complete', models, _models

        options.success?(_models)

    fetchPostFromMention = (mention) =>
      TentStatus.tent_client.post.get(
        params: {
          entity: mention.entity
          post: mention.post
        }

        headers: {
          'Cache-Control': 'proxy-if-miss'
        }

        callback: (res, xhr) =>
          fetchPostComplete(mention, res, xhr)
      )

    mentionsMompleteFn = (res, xhr) =>
      if xhr.status == 200
        num_pending_posts = res.mentions.length
        for mention in res.mentions
          continue unless mention.type == TentStatus.config.POST_TYPES.STATUS_REPLY
          mentions.push(mention)
          fetchPostFromMention(mention)
      else
        options.failure?(res, xhr)

    TentStatus.tent_client.post.mentions(
      params: {
        entity: @get('entity')
        post: @get('id')
        limit: TentStatus.config.CONVERSATION_PER_PAGE
      }

      headers: {
        'Cache-Control': 'proxy'
      }

      callback: mentionsMompleteFn
    )

    null

