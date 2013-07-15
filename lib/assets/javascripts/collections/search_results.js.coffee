TentStatus.Collections.SearchResults = class SearchResultsCollection extends TentStatus.Collection
  @id_mapping_scope: ['entity', 'context']
  @collection_name: 'posts_collection'

  constructor: (options = {}) ->
    @api_root = options.api_root
    throw new Error("#{@constructor.name} requires options.api_root!") unless @api_root

    super

    # id mapping
    @set('entity', @options.entity || TentStatus.config.meta.content.entity)
    @set('context', @options.context || 'default')

  fetch: (params = {}, options = {}) =>
    client = new Marbles.HTTP.Client middleware: [Marbles.HTTP.Middleware.SerializeJSON]
    client.get(
      url: @api_root
      params: @searchParams(params)
      callback: (res, xhr) => @fetchComplete(params, options, res, xhr)
    )

  searchParams: (params = {}) =>
    params = _.clone(params)
    [q, entity, types] = [params.q || '', params.entity, params.types || TentStatus.config.feed_types]
    delete params.entity
    delete params.types

    params.api_key = TentStatus.config.services.search_api_key
    params.entity = entity if entity
    params.types = types

    params

