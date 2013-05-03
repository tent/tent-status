class EntitySearchService
  constructor: (@options = {}) ->
    @client = new Marbles.HTTP.Client(middleware: [Marbles.HTTP.Middleware.SerializeJSON])

  # options:
  #   - success: fn
  #   - error: fn
  #   - complete: fn
  search: (query, options = {}) =>
    @client.get @options.api_root, { q: query }, options

_.extend EntitySearchService::, Marbles.Events
_.extend EntitySearchService::, Marbles.Accessors

if (api_root = TentStatus.config.entity_search_api_root)
  TentStatus.services ?= {}
  TentStatus.services.entity_search = new EntitySearchService(api_root: api_root)

