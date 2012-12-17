TentStatus.Collection = class Collection
  @model: TentStatus.Model

  fetch: (params = {}, options = {}) =>
    options.client ?= @client || HTTP.TentClient.currentEntityClient()
    options.client.get @constructor.model.resource_path, _.extend({}, (@params || @constructor.params), params), (res, xhr) =>
      unless xhr.status == 200
        options.error?(res, xhr)
        @trigger('fetch:failed', res, xhr)
        return

      if options.append
        models = @append(res)
      else
        models = @reset(res)

      options.success?(models, xhr, @)
      @trigger('fetch:success', @)

  reset: (resources_attribtues = []) =>
    @model_ids = []
    @append(resources_attribtues)

  includes: (model) =>
    return @model_ids.indexOf(model.cid) != -1

  remove: (models...) =>
    for model in models
      cid = model.cid
      index = @model_ids.indexOf(cid)
      continue if index == -1
      @model_ids = @model_ids.slice(0, index).concat(@model_ids.slice(index+1, @model_ids.length))
    @model_ids.length

  append: (resources_attribtues = {}) =>
    for attrs in resources_attribtues
      model = new @constructor.model(attrs)
      @model_ids.push(model.cid)
      model

  unshift: (models...) =>
    for model in models
      @model_ids.unshift(model.cid)
    @model_ids.length

  push: (models...) =>
    for model in models
      @model_ids.push(model.cid)
    @model_ids.length

  models: (cids = @model_ids) =>
    models = []
    for cid in (cids || [])
      model = @constructor.model.find({ cid: cid })
      models.push(model) if model
    models

_.extend Collection::, TentStatus.Events

