AVATAR_EXP_TIMESTAMP = 1376669460 + 3154000000 # 100 years from 2013-08-16 -0400

TentStatus.Models.MetaProfile = class  MetaProfileModel extends Marbles.Model
  @model_name: 'meta_profile'
  @id_mapping_scope: ['entity']

  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.META)

  @fetch: (entity, options = {}) ->
    if entity.hasOwnProperty?('entity')
      params = entity
    else
      params = {entity:entity}

    failureFn = (res, xhr) =>
      @trigger("fetch:failure", params, res, xhr)
      @trigger("#{entity}:fetch:failure", params, res, xhr)
      options.failure?(res, xhr)
      options.complete?(res, xhr)

    if !TentStatus.tent_client.credentials
      failureFn()
      return

    completeFn = (res, xhr) =>
      if xhr.status != 200
        failureFn(res, xhr)
        return

      constructorFn = @
      server_meta_post = res.post

      attrs = _.extend({
        id: server_meta_post.id
        entity: server_meta_post.content.entity
        avatar_digest: server_meta_post.attachments?[0]?.digest
      }, server_meta_post.content.profile || {})

      model = constructorFn.find(entity, fetch: false)

      if model
        model.parseAttributes(attrs)
      else
        model = new constructorFn(attrs)

      @trigger("fetch:success", model, xhr)
      @trigger("#{entity}:fetch:success", model, xhr)
      options.success?(model, xhr)
      options.complete?(res, xhr)

    TentStatus.tent_client.discover(
      params: params
      callback: completeFn
    )

  constructor: ->
    @on 'change:avatar_digest', (digest) =>
      if digest
        @set('avatar_url', TentStatus.tent_client.getSignedUrl('attachment', entity: @get('entity'), digest: digest, exp: AVATAR_EXP_TIMESTAMP))
      else
        @set('avatar_url', TentStatus.config.defaultAvatarURL(@get('entity')))

    super

  parseAttributes: =>
    super

    unless @get('avatar_url')
      @set('avatar_url', TentStatus.config.defaultAvatarURL(@get('entity')))

  fetch: (options = {}) =>
    @constructor.fetch(@get('entity'), options)

TentStatus.once 'config:ready', ->
  meta = TentStatus.config.meta
  TentStatus.meta_profile = new MetaProfileModel(_.extend(
    {
      entity: meta.content.entity,
      avatar_digest: meta.attachments?[0]?.digest
    },
    meta.content.profile || {}
  ))
