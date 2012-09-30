class TentStatus.FetchPool extends TentStatus.Paginator
  constructor: (@collection, @options = {}) ->
    super
    @sinceId = @options.sinceId
    @options.is_background_operation = true

  paramsForOffsetAndLimit: (since_id_entity, sinceId, limit) =>
    params = _.extend { limit: limit }, @default_params
    params.since_id = sinceId if sinceId
    params.since_id_entity = since_id_entity if since_id_entity
    params

  fetch: (options = {}) =>
    super(_.extend {
      n_pages: 'infinite'
    }, options)

  filterNewItems: (items, collection=@collection) =>
    super(super(items, collection), @options.master_collection)

