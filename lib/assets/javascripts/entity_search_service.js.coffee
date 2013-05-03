class EntitySearchService
  constructor: (@options = {}) ->
    @client = new Marbles.HTTP.Client middleware: [Marbles.HTTP.Client.Middleware.SerializeJSON]

  # options:
  #   - success: fn
  #   - error: fn
  #   - complete: fn
  search: (query, options = {}) =>
    @client.get @options.api_root, { q: query }, options

_.extend EntitySearchService::, Marbles.Events
_.extend EntitySearchService::, Marbles.Accessors

if TentStatus.config.entity_search_service_api_root
  TentStatus.entity_search_service = new EntitySearchService api_root: TentStatus.config.entity_search_service_api_root
