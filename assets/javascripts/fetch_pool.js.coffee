class TentStatus.FetchPool extends TentStatus.Paginator
  constructor: (@collection, @options = {}) ->
    super
    @sinceId = @options.sinceId

  paramsForOffsetAndLimit: (sinceId, limit) =>
    params = { limit: limit }
    params.since_id = sinceId if sinceId
    params

  fetch: (options = {}) =>
    super(_.extend {
      n_pages: 'infinite'
    }, options)

  filterNewItems: (items, collection=@collection) =>
    super(super(items, collection), @options.master_collection)

