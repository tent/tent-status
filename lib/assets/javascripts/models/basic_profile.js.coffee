TentStatus.Models.BasicProfile = class BasicProfileModel extends Marbles.Model
  @model_name: 'basic_profile'
  @id_mapping_scope: ['entity']

  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.BASIC_PROFILE)

  @content_fields = ['name', 'bio', 'location', 'gender', 'birthdate', 'website_url']

  parseAttributes: =>
    super
    @attachmentsUpdated(@get('attachments'))

  fetch: (params = {}, options = {}) =>
    xhr = null
    entity = params.entity || @get('entity')

    if not(entity)
      throw new Error("#{@constructor.name}.prototype.fetch requires an entity!")

    success = =>
      options.success?(@, xhr)
      @trigger('fetch:success', @, xhr)
    failure = =>
      options.failure?(@, xhr)
      @trigger('fetch:failure', @, xhr)

    TentStatus.tent_client.post.list(
      params:
        entity: entity
        types: [@constructor.post_type.toString()]
        limit: 1
      callback: (feed, xhr) =>
        return failure() unless xhr.status in [200...300]
        posts = feed.data
        return failure() unless posts.length && post = _.find(posts, (item) =>
          (new TentClient.PostType(item.type)).base == @constructor.post_type.base
        )
        @parseAttributes(post)
        success()
    )

  attachmentsUpdated: (value) =>
    setDefaultAvatar = =>
      @set('avatar_url', TentStatus.config.DEFAULT_AVATAR_URL)

    return setDefaultAvatar() unless value && value.length
    return setDefaultAvatar() unless avatar_attachment = _.find value, (attachment) =>
      attachment.category == 'avatar'
    url = TentAdmin.tent_client.getNamedUrl('attachment',
      entity: @get('entity')
      digest: avatar_attachment.digest
    )
    @set('avatar_url', url)

