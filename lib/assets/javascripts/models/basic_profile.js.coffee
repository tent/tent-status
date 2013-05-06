TentStatus.Models.BasicProfile = class BasicProfileModel extends Marbles.Model
  @model_name: 'basic_profile'
  @id_mapping_scope: ['entity']

  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.BASIC_PROFILE)

  @content_fields = ['name', 'bio', 'location', 'gender', 'birthdate', 'website_url']

  @fetch: (params = {}, options = {}) ->
    entity = params.entity || options.model?.get('entity')

    if not(entity)
      throw new Error("#{@name}.fetch requires an entity!")

    success = (model, xhr) =>
      options.success?(model, xhr)
      model.trigger('fetch:success', model, xhr)
      @trigger('fetch:success', model, xhr)
    failure = (model, res, xhr) =>
      options.failure?(model, res, xhr)
      model?.trigger('fetch:failure', model, res, xhr)
      @trigger('fetch:failure', model, res, xhr)

    TentStatus.tent_client.post.list(
      params:
        entity: entity
        types: [@post_type.toString()]
        limit: 1
      callback: (feed, xhr) =>
        return failure(options.model, feed, xhr) unless xhr.status in [200...300]
        posts = feed.data
        return failure(options.model, feed, xhr) unless posts.length && post = _.find(posts, (item) =>
          (new TentClient.PostType(item.type)).base == @post_type.base
        )
        model = new @(post)
        success(model, xhr)
    )

  parseAttributes: =>
    super
    @attachmentsUpdated(@get('attachments'))

  fetch: (params = {}, options = {}) =>
    @constructor.fetch(params, _.extend(model: @, options))

  attachmentsUpdated: (value) =>
    setDefaultAvatar = =>
      @set('avatar_url', TentStatus.config.DEFAULT_AVATAR_URL)

    return setDefaultAvatar() unless value && value.length
    return setDefaultAvatar() unless avatar_attachment = _.find value, (attachment) =>
      attachment.category == 'avatar'
    url = TentStatus.tent_client.getNamedUrl('attachment',
      entity: @get('entity')
      digest: avatar_attachment.digest
    )
    @set('avatar_url', url)

