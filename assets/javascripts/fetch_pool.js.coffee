class TentStatus.FetchPool extends TentStatus.Paginator
  constructor: (@collection, @options = {}) ->
    super
    @sinceId = @options.sinceId

  paramsForOffsetAndLimit: (sinceId, limit) =>
    params = { limit: limit }
    params.since_id = sinceId if sinceId
    params

  fetch: (options = {}) =>
    _options = {
      success: (items) =>
        newItems = []
        existingItems = TentStatus.Collections.posts.toArray()
        for i in items
          newItems.push i unless existingItems.indexOf(i)

        if newItems.length
          @sinceId = items.last()?.get('id') || @sinceId
          @options.success?()
          @trigger 'fetch:success'
    }
    options = _.extend _options, options
    super(options)
