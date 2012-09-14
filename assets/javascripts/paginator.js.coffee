class StatusApp.Paginator
  page: 1
  limit: 20
  onLastPage: false
  isPaginator: true

  offset: => (@page - 1) * @limit

  constructor: (@collection) ->
    @url ||= @collection.url?()
    @url ||= @collection.url

  refresh: =>
    cache = @toArray()
    _page = @page
    _limit = @limit
    @page = 1
    @limit = _page * _limit

    @fetch
      add: false
      success: =>
        @page = _page
        @limit = _limit

        @trigger 'fetch:success'

  fetch: (options = {}) =>
    offset = @offset()
    limit = @limit

    @trigger 'fetch:start'

    loadedCount = @collection.length
    expectedCount = loadedCount + limit

    _options = {
      url: @urlForOffsetAndLimit(offset, limit)
      add: true
      success: =>
        if (loadedCount == @collection.length) or (@collection.length < expectedCount)
          @onLastPage = true
        @trigger 'fetch:success'
      error: =>
        @page = @oldPage
        @trigger 'fetch:error'
    }
    options = _.extend _options, options

    @collection.fetch(options)

  urlForOffsetAndLimit: (offset, limit) =>
    separator = if @url.indexOf("?") != -1 then "&" else "?"
    @url + separator + @serializeParams(@paramsForOffsetAndLimit offset, limit)

  serializeParams: (params = {}) =>
    res = []
    for k, v of params
      continue if @url.match("#{k}=")
      res.push "#{k}=#{v}"
    res.join("&")

  paramsForOffsetAndLimit: (offset, limit) =>
    offset: offset
    limit: limit

  nextPage: =>
    @oldPage = @page
    ++@page
    @fetch()

  toJSON: => @collection.toJSON()
  toArray: => @collection.toArray()
  find: => @collection.find(arguments...)

_
