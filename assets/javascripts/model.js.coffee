TentStatus.Model = class Model
  @instances: {
    all: {}
  }
  @id_mapping: {}
  @_id_counter: 0
  @model_name: '_default'

  @find: (params, options = {}) ->
    if params.id && (cid = @id_mapping[@model_name]?[params.id])
      params.cid = cid

    if params.cid
      instance = @instances.all[params.cid]
      if !params.hasOwnProperty('entity') || instance.get('entity') == params.entity
        options.success?(instance)
        return instance
      else
        delete params.cid

    if params.id && (!options.hasOwnProperty('fetch') || options.fetch) && (!params.hasOwnProperty('fetch') || params.fetch)
      @fetch(params, options)

    null

  @fetch: (params, options) ->
    console.warn("You need to define #{@name}::fetch(params, callback)!")

  # delete reference
  @detach: (cid) ->
    delete @instances.all[cid]

    if index = @instances[@model_name]?.indexOf(cid)
      instances = @instances[@model_name]
      instances = instances.slice(0, index).concat(instances.slice(index+1, instances.length))
      @instances[@model_name] = instances

    for _id, _cid of @id_mapping
      if _cid == cid
        delete @id_mapping[_id]
        break

  detach: =>
    @constructor.detach(@cid)

  constructor: (attributes, @options = {}) ->
    @generateCid()
    @trackInstance()
    @on 'change:id', @updateIdMapping
    @parseAttributes(attributes)

  generateCid: =>
    @cid = "#{@constructor.model_name}_#{@constructor._id_counter++}"

  trackInstance: =>
    @constructor.instances.all[@cid] = @
    @constructor.instances[@constructor.model_name] ?= []
    @constructor.instances[@constructor.model_name].push @cid

  parseAttributes: (attributes) =>
    @set(k, v, {keypath:false}) for k,v of attributes

  updateIdMapping: (new_id, old_id) =>
    @constructor.id_mapping[@constructor.model_name] ?= {}
    delete @constructor.id_mapping[@constructor.model_name][old_id]
    @constructor.id_mapping[@constructor.model_name][new_id] = @cid

  set: (keypath, v, options={}) =>
    return unless keypath && keypath.length
    if !options.hasOwnProperty('keypath') || options.keypath
      keys = keypath.split('.')
    else
      keys = [keypath]

    @fields ?= []
    @fields.push(keys[0]) if @fields.indexOf(keys[0]) == -1

    TentStatus.Accessors.set.apply(@, arguments)

  get: (keypath, options={}) =>
    return unless keypath && keypath.length
    if !options.hasOwnProperty('keypath') || options.keypath
      keys = keypath.split('.')
    else
      keys = [keypath]

    return if @fields.indexOf(keys[0]) == -1

    TentStatus.Accessors.get.apply(@, arguments)

  toJSON: =>
    attrs = {}
    for k in (@fields || [])
      attrs[k] = @[k]
    attrs

_.extend Model, TentStatus.Events
_.extend Model::, TentStatus.Events
