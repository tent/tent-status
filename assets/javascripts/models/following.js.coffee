TentStatus.Models.Following = class FollowingModel extends TentStatus.Model
  @model_name: 'following'
  @resource_path: 'followings'
  @entity_mapping: {}

  @find: (params, options = {}) ->
    if params.id && (cid = @id_mapping[@model_name]?[params.id])
      params.cid = cid

    if params.entity && (cid = @entity_mapping[params.entity])
      params.cid = cid

    if params.cid
      instance = @instances.all[params.cid]
      options.success?(instance)
      return instance

    if (params.id || params.entity) && (!options.hasOwnProperty('fetch') || options.fetch) && (!params.hasOwnProperty('fetch') || params.fetch)
      @fetch(params, options)

    null

  @fetch: (params, options = {}) ->
    unless options.client
      return HTTP.TentClient.find entity: (options.entity || TentStatus.config.current_entity), (client) =>
        @fetch(params, _.extend(options, {client: client}))

    options.client.get "#{@resource_path}/#{encodeURIComponent(params.id || params.entity)}", null, (res, xhr) =>
      unless xhr.status == 200
        options.error?(res, xhr)
        @trigger('fetch:failed', res, xhr)
        return

      following = new @(res)
      options.success?(following, xhr)
      @trigger('fetch:success', following, xhr)

  @create: (params, options = {}) ->
    options.client ?= HTTP.TentClient.currentEntityClient()

    options.client.post @resource_path, { entity: params.entity }, (res, xhr) =>
      unless xhr.status == 200
        options.error?(res, xhr)
        @trigger('create:failed', res, xhr)
        return

      following = new @(res)
      options.success?(following, xhr)
      @trigger('create:success', following, xhr)

  @delete: (following, options = {}) ->
    options.client ?= HTTP.TentClient.currentEntityClient()

    options.client.delete "#{@resource_path}/#{following.get('id')}", null, (res, xhr) =>
      unless xhr.status == 200
        options.error?(res, xhr)
        @trigger('delete:failed', res, xhr)
        return

      following.detach()
      options.success?(following, xhr)
      @trigger('delete:success', following, xhr)

  @validate: (attrs, options = {}) ->
    errors = []

    if !attrs.entity || !attrs.entity.match(/^https?:\/\/.+$/)
      errors.push { entity: 'Must be valid entity URI' }

    return errors if errors.length
    null

  @detach: (cid) ->
    for entity, _cid of @entity_mapping
      if _cid == cid
        delete @entity_mapping[entity]
        break

    super

  delete: (options = {}) =>
    @constructor.delete(@, options)

  constructor: ->
    super
    @constructor.entity_mapping[@get('entity')] = @cid if @get('current_entity_host') == true

