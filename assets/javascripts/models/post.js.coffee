TentStatus.Models.Post = class PostModel extends TentStatus.Model
  @model_name: 'post'
  @resource_path: 'posts'

  @create: (data, options = {}) ->
    client = HTTP.TentClient.currentEntityClient()
    client.post '/posts', data, (res, xhr) =>
      unless xhr.status == 200
        @trigger('create:failed', res, xhr)
        options.error?(res, xhr)
        return

      post = new @(res)
      @trigger('create:success', post, xhr)
      options.success?(post, xhr)

  @update: (post, data, options = {}) ->
    client = HTTP.TentClient.currentEntityClient()
    client.put "/posts/#{post.get('id')}", data, (res, xhr) =>
      unless xhr.status == 200
        post.trigger('update:failed', res, xhr)
        options.error?(res, xhr)
        return

      post.parseAttributes(res)
      post.trigger('update:success', post, xhr)
      options.success?(post, xhr)

  @delete: (post, options = {}) ->
    client = HTTP.TentClient.currentEntityClient()
    client.delete "/posts/#{post.get('id')}", null, (res, xhr) =>
      unless xhr.status == 200
        post.trigger('delete:failed', res, xhr)
        options.error?(res, xhr)
        return

      post.detach()
      post.trigger('delete:success', post, xhr)
      options.success?(post, xhr)

  @fetchCount: (params, options = {}) ->
    params.fetch_params ?= { post_types: TentStatus.config.post_types }
    super(params, options)

  @fetch: (params, options = {}) ->
    unless options.client
      return HTTP.TentClient.find entity: (params.entity || TentStatus.config.current_entity), (client) =>
        @fetch(params, _.extend(options, {client: client}))

    path = if params.entity
      "/posts/#{encodeURIComponent params.entity}/#{params.id}"
    else
      "/posts/#{params.id}"

    _params = _.clone(params)
    delete _params.id
    delete _params.entity
    options.client.get path, _params, (res, xhr) =>
      if xhr.status != 200
        @trigger("fetch:failed", params, res, xhr)
        options.error?(res, xhr)
        return

      return if @find(params, _.extend(options, {fetch:false}))
      post = new @(res)

      @trigger("fetch:success", params, post, xhr)
      options.success?(post, xhr)

  @validate: (attrs, options = {}) ->
    errors = []

    if (attrs.content?.text and attrs.content.text.match /^[\s\r\t]*$/) || (options.validate_empty and attrs.content?.text == "")
      errors.push { text: 'Status must not be empty' }

    if attrs.content?.text and attrs.content.text.length > TentStatus.config.MAX_LENGTH
      errors.push { text: "Status must be no more than #{TentStatus.config.MAX_LENGTH} characters" }

    return errors if errors.length
    null

  update: (data, options = {}) =>
    @constructor.update(@, data, options)

  delete: (options = {}) =>
    @constructor.delete(@, options)

  isRepost: =>
    !!(@get('type') || '').match(/repost/)

  entityMentioned: (entity) =>
    _.any @get('mentions'), (m) => m.entity == entity

  postMentions: =>
    @post_mentions ?= _.select @get('mentions') || [], (m) => m.entity && m.post

  replyToEntities: (options = {}) =>
    _entities = []
    for m in [{ entity: @get('entity') }].concat(@get('mentions'))
      continue unless m && m.entity
      continue if TentStatus.Helpers.isCurrentUserEntity(m.entity)
      _entity = m.entity
      _entity = TentStatus.Helpers.minimalEntity(_entity) if options.trim
      _entities.push(_entity) if _entities.indexOf(_entity) == -1
    _entities

  fetchChildMentions: (options = {}) =>
    unless options.client
      return HTTP.TentClient.find {entity: @get('entity')}, (client) =>
        @fetchChildMentions(_.extend(options, {client: client}))

    params = _.extend({
      limit: TentStatus.config.PER_CONVERSATION_PAGE
      post_types: TentStatus.config.post_types
    }, options.params || {})

    options.client.get "/posts/#{@get('id')}/mentions", params, {
      success: options.success
      error: options.error
      complete: options.complete
    }

    null

