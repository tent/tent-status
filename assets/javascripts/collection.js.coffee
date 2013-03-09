TentStatus.Collection = class Collection extends Marbles.Collection
  ignore_cids: []

  fetch: (params = {}, options = {}) =>
    options.client ?= @client || Marbles.HTTP.TentClient.currentEntityClient()
    params = _.extend({}, (@params || @constructor.params), params)
    options.client.get @constructor.model.resource_path, params, (res, xhr) =>
      unless xhr.status == 200
        options.error?(res, xhr)
        @trigger('fetch:failed', res, xhr)
        return

      @parseLinkHeader(xhr.getResponseHeader('Link')) if res.length

      if options.append
        models = @append(res)
      else if options.prepend
        models = @prepend(res)
      else
        models = @reset(res)

      options.success?(models, xhr, params, options, @)
      @trigger('fetch:success', @)

  fetchPrev: (options = {}) =>
    unless @pagination_params?.prev
      options.error?([])
      return []
    @fetch(@pagination_params.prev, options)

  fetchNext: (options = {}) =>
    unless @pagination_params?.next
      options.error?([])
      return []
    @fetch(@pagination_params.next, options)

  parseLinkHeader: (link_header="") =>
    @pagination_params = (new TentStatus.PaginationLinkHeader link_header).pagination_params

  append: (resources_attribtues) =>
    return [] unless resources_attribtues?.length
    models = []
    for attrs in resources_attribtues
      model = @constructor.model.find(
        id: attrs.id
        entity: attrs.entity
        fetch: false
      ) || new @constructor.model(attrs)
      continue if @ignore_cids.indexOf(model.cid) != -1
      models.push(model)
      @model_ids.push(model.cid)
      model
    models

  prepend: (resources_attribtues) =>
    return [] unless resources_attribtues?.length
    models = []
    for i in [resources_attribtues.length-1..0]
      attrs = resources_attribtues[i]
      model = @constructor.model.find(
        id: attrs.id
        entity: attrs.entity
        fetch: false
      ) || new @constructor.model(attrs)
      continue if @ignore_cids.indexOf(model.cid) != -1
      models.push(model)
      @model_ids.unshift(model.cid)
      model
    models

  prependModels: (model_ids) =>
    @model_ids = model_ids.concat(@model_ids)

  ignoreCid: (model_cid) =>
    @ignore_cids.push model_cid
    @remove(cid: model_cid)

  empty: =>
    @model_ids = []

