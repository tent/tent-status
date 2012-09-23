class TentStatus.FetchPool extends TentStatus.Paginator
  constructor: (@collection, @options = {}) ->
    super
    @sinceId = @options.sinceId

  paramsForOffsetAndLimit: (since_id_entity, sinceId, limit) =>
    params = { limit: limit }
    params.since_id = sinceId if sinceId
    params.since_id_entity = since_id_entity if since_id_entity
    params

  fetch: (options = {}) =>
    super(_.extend {
      n_pages: 'infinite'
    }, options)

  filterNewItems: (items, collection=@collection) =>
    super(super(items, collection), @options.master_collection)

