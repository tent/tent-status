TentStatus.Models.Post = class PostModel extends Marbles.Model
  @model_name: 'post'
  @id_mapping_scope: ['id', 'entity']

  @create: (data, options = {}) ->
    completeFn = (res, xhr) =>
      unless xhr.status == 200
        @trigger('create:failure', res, xhr)
        options.failure?(res, xhr)
        return

      post = new @(res)
      @trigger('create:success', post, xhr)
      options.success?(post, xhr)

    TentStatus.tent_client.post.create(
      body: data
      callback: completeFn
    )

  @update: (post, data, options = {}) ->
    completeFn = (res, xhr) =>
      unless xhr.status == 200
        post.trigger('update:failure', res, xhr)
        options.failure?(res, xhr)
        return

      post.parseAttributes(res)
      post.trigger('update:success', post, xhr)
      options.success?(post, xhr)

    data.versions ?= { parents: [{ version: post.get('version.id') }] }

    TentStatus.tent_client.post.update(
      params:
        post: post.get('id')
        entity: post.get('entity')
      body: data
      complete: completeFn
    )

  @delete: (post, options = {}) ->
    completeFn = (res, xhr) =>
      unless xhr.status == 200
        post.trigger('delete:failure', res, xhr)
        options.failure?(res, xhr)
        return

      post.detach()
      post.trigger('delete:success', post, xhr)
      options.success?(post, xhr)

    TentStatus.tent_client.post.delete(
      params:
        post: post.get('id')
        entity: post.get('entity')
      callback: completeFn
    )

  @fetchCount: (params, options = {}) ->
    return unless params.entity && @post_type

    completeFn = (data, xhr) =>
      unless xhr.status == 200
        options.failure?(res, xhr)
        return

      count = parseInt(xhr.getResponseHeader('Count'))
      return unless typeof count is 'number'
      return if count.toString() is 'NaN'

      options.success?(count, xhr)

    TentStatus.tent_client.post.list(
      method: 'HEAD'
      params: _.extend({
        types: [@post_type.toString()]
      }, params)
      callback: completeFn
    )

  @fetch: (params, options = {}) ->
    completeFn = (res, xhr) =>
      if xhr.status != 200
        @trigger("fetch:failure", params, res, xhr)
        options.failure?(res, xhr)
        options.complete?(res, xhr)
        return

      constructorFn = _.find [TentStatus.Models.StatusPost, TentStatus.Models.StatusReplyPost], (c) =>
        c.post_type.assertMatch(new TentClient.PostType res.type)
      constructorFn ?= @

      if params.cid
        if post = @instances.all[params.cid]
          post.parseAttributes(res)
        else
          post = new constructorFn(res, cid: params.cid)
      else
        post = new constructorFn(res)

      @trigger("fetch:success", post, xhr)
      options.success?(post, xhr)
      options.complete?(res, xhr)

    TentStatus.tent_client.post.get(
      params:
        post: params.id
        entity: params.entity
      callback: completeFn
    )

  parseAttributes: (attrs) =>
    attrs.permissions ?= { public: true }
    if attrs.mentions
      for m in attrs.mentions
        m.entity ?= attrs.entity
    super(attrs)
    @updateRepostFlag(@get('type'))
    @updateMentionedPosts(@get('mentions'))
    @updateConversationEntities(@get('mentions'))

  updateRepostFlag: (type) =>
    type = new TentClient.PostType(type) if type
    if type && type.base && type.base == (new TentClient.PostType(TentStatus.config.POST_TYPES.REPOST)).base
      @set('is_repost', true)
    else
      @set('is_repost', false)

  updateMentionedPosts: (mentions) =>
    if mentions && mentions.length
      mentioned_posts = _.map(_.select(mentions, ((m) => !!m.post)), (m) =>
        m.entity ?= @get('entity')
        m
      )
      @set('mentioned_posts', mentioned_posts)
    else
      @set('mentioned_posts', [])

  updateConversationEntities: (mentions) =>
    _entities = []
    for m in [{ entity: @get('entity') }].concat(mentions)
      continue unless m && m.entity
      continue if TentStatus.Helpers.isCurrentUserEntity(m.entity)
      _entity = m.entity
      _entities.push(_entity) if _entities.indexOf(_entity) == -1
    @set('conversation_entities', _entities)

  fetch: (options = {}) =>
    @constructor.fetch({
      cid: @cid
      id: @get('id')
      entity: @get('entity')
    }, options)

  update: (data, options = {}) =>
    @constructor.update(@, data, options)

  delete: (options = {}) =>
    @constructor.delete(@, options)

  isEntityMentioned: (entity) =>
    _.any @get('mentions'), (m) => m.entity == entity

