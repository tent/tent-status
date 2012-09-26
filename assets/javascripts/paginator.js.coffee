class TentStatus.Paginator
  sinceId: null
  since_id_entity: null
  prevSinceId: null
  limit: TentStatus.PER_PAGE || 50
  onLastPage: false
  isPaginator: true

  constructor: (@collection, @options = {}) ->
    @url = @options.url if @options.url
    @url ||= @collection.url?()
    @url ||= @collection.url
    @sinceId = @options.sinceId if @options.sinceId
    @since_id_entity = @options.since_id_entity if @options.since_id_entity
    @default_params = @options.params if @options.params

  freeze: => @frozen = true
  unfreeze: => @frozen = false

  fetch: (options = {}) =>
    sinceId = @sinceId
    since_id_entity = @since_id_entity
    limit = @limit

    options.push_method ?= 'push'

    return if @frozen
    unless options.n_pages == 'infinite'
      entity_match = if @prev_since_id_entity then @prev_since_id_entity == since_id_entity else true
      return if entity_match && @prevSinceId and sinceId == @prevSinceId

    @freeze()
    @trigger 'fetch:start'

    loadedCount = @collection.length
    expectedCount = loadedCount + limit

    params = @paramsForOffsetAndLimit(since_id_entity, sinceId, limit)
    new HTTP 'GET', @url, params, (items, xhr) =>
      @unfreeze()
      unless xhr.status == 200
        @trigger 'fetch:error'
        @onLastPage = true unless options.n_pages == 'infinite'
        return

      items = @filterNewItems(items)
      for i in items
        i = new @collection.model i
        @sinceId = i.get('id')
        @since_id_entity = i.get('entity') if since_id_entity
        @collection[options.push_method](i)

      unless options.n_pages == 'infinite'
        if loadedCount == @collection.length or (@collection.length < expectedCount)
          @onLastPage = true

      @prevSinceId = sinceId
      @prev_since_id_entity = since_id_entity
      @trigger 'fetch:success'

  filterNewItems: (items, collection=@collection) =>
    collection_ids = collection.map (i) => i.get('id')
    new_items = []
    for i in items
      continue unless collection_ids.indexOf(i.id) == -1
      new_items.push i
    new_items

  urlForOffsetAndLimit: (since_id_entity, sinceId, limit) =>
    separator = if @url.match(/\?/) then "&" else "?"
    @url + separator + @serializeParams(@paramsForOffsetAndLimit since_id_entity, sinceId, limit)

  serializeParams: (params = {}) =>
    res = []
    for k, v of params
      continue if @url.match("#{k}=")
      res.push "#{k}=#{v}"
    res.join("&")

  paramsForOffsetAndLimit: (since_id_entity, sinceId, limit) =>
    params = _.extend { limit: limit }, @default_params
    params.before_id = sinceId if sinceId
    params.before_id_entity = since_id_entity if since_id_entity
    params

  nextPage: =>
    @fetch()

  toJSON: => @collection.toJSON()
  toArray: => @collection.toArray()
  find: => @collection.find(arguments...)
  filter: => @collection.filter(arguments...)
  sortBy: => @collection.sortBy(arguments...)
  get: => @collection.get(arguments...)
  unshift: => @collection.unshift(arguments...)
  push: => @collection.push(arguments...)
  first: => @collection.first(arguments...)
  last: => @collection.last(arguments...)
  map: => @collection.map(arguments...)

_.extend TentStatus.Paginator::, Backbone.Events
