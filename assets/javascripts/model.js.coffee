TentStatus.Model = class Model
  @instances: {
    all: {}
  }
  @id_mapping: {}
  @_id_counter: 0
  @model_name: '_default'

  @find: (params, callback) ->
    if params.id && (cid = @id_mapping[@model_name]?[params.id])
      params.cid = cid

    if params.cid
      instance = @instances.all[params.cid]
      callback?(instance)
      return instance

    if params.id
      @fetch(params, callback)

  @fetch: (params, callback) ->
    console.warn("You need to define #{@name}::fetch(params, callback)!")

  constructor: (attributes, @options) ->
    @generateCid()
    @on 'change:id', @updateIdMapping
    @parseAttribtues(attributes)
    @trackInstance()

  parseAttribtues: (attributes) =>
    @set(k, v) for k,v of attributes

  generateCid: =>
    @cid = "#{@constructor.model_name}_#{@constructor._id_counter++}"

  trackInstance: =>
    @constructor.instances.all[@cid] = @
    @constructor.instances[@constructor.model_name] ?= []
    @constructor.instances[@constructor.model_name].push @cid

  updateIdMapping: (new_id, old_id) =>
    @constructor.id_mapping[@constructor.model_name] ?= {}
    delete @constructor.id_mapping[@constructor.model_name][old_id]
    @constructor.id_mapping[@constructor.model_name][new_id] = @cid

  set: (k, v) =>
    @fields ?= []
    @fields.push(k) if @fields.indexOf(k) == -1
    old_v = @[k]
    @[k] = v
    @trigger("change:#{k}", v, old_v) unless v == old_v
    v

  get: (k) =>
    @[k] if @fields.indexOf(k) != -1

_.extend Model::, Backbone.Events
