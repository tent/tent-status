class StatusApp.Paginator
  sinceId: null
  limit: StatusApp.PER_PAGE || 50
  onLastPage: false
  isPaginator: true

  constructor: (@collection, @options = {}) ->
    @url = @options.url if @options.url
    @url ||= @collection.url?()
    @url ||= @collection.url

  fetch: (options = {}) =>
    sinceId = @sinceId
    limit = @limit

    @trigger 'fetch:start'

    loadedCount = @collection.length
    expectedCount = loadedCount + limit

    _options = {
      url: @urlForOffsetAndLimit(sinceId, limit)
      add: true
      success: (items) =>
        if (loadedCount == @collection.length) or (@collection.length < expectedCount)
          @onLastPage = true
        @sinceId = items.last().get('id')
        @options.success?()
        @trigger 'fetch:success'
      error: =>
        @page = @oldPage
        @trigger 'fetch:error'
    }
    options = _.extend _options, options

    @collection.fetch(options)

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
  first: => @collection.first(arguments...)

_.extend StatusApp.Paginator::, Backbone.Events
