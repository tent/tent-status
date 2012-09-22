class TentStatus.Paginator
  sinceId: null
  prevSinceId: null
  limit: TentStatus.PER_PAGE || 50
  onLastPage: false
  isPaginator: true

  constructor: (@collection, @options = {}) ->
    @url = @options.url if @options.url
    @url ||= @collection.url?()
    @url ||= @collection.url
    @sinceId = @options.sinceId if @options.sinceId

  freeze: => @frozen = true
  unfreeze: => @frozen = false

  fetch: (options = {}) =>
    sinceId = @sinceId
    limit = @limit

    return if @frozen
    return if @prevSinceId and sinceId == @prevSinceId

    @freeze()
    @trigger 'fetch:start'

    loadedCount = @collection.length
    expectedCount = loadedCount + limit

    new HTTP 'GET', @url, @paramsForOffsetAndLimit(sinceId, limit), (items, xhr) =>
      @unfreeze()
      unless xhr.status == 200
        @trigger 'fetch:error'
        @onLastPage = true
        return

      collection_ids = @collection.map (i) => i.get('id')
      for i in items
        i = new @collection.model i
        continue unless collection_ids.indexOf(i.get('id')) == -1
        @sinceId = i.get('id')
        @collection.push(i)

      if loadedCount == @collection.length or (@collection.length < expectedCount)
        @onLastPage = true

      @prevSinceId = sinceId
      @trigger 'fetch:success'

  urlForOffsetAndLimit: (sinceId, limit) =>
    separator = if @url.indexOf("?") != -1 then "&" else "?"
    @url + separator + @serializeParams(@paramsForOffsetAndLimit sinceId, limit)

  serializeParams: (params = {}) =>
    res = []
    for k, v of params
      continue if @url.match("#{k}=")
      res.push "#{k}=#{v}"
    res.join("&")

  paramsForOffsetAndLimit: (sinceId, limit) =>
    params = { limit: limit }
    params.before_id = sinceId if sinceId
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

_.extend TentStatus.Paginator::, Backbone.Events
