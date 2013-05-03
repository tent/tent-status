class EntitySearchService
  constructor: (@options = {}) ->
    @client = new Marbles.HTTP.Client(middleware: [Marbles.HTTP.Middleware.SerializeJSON])

  # callback can either be a function or an object:
  #   - success: fn
  #   - error: fn
  #   - complete: fn
  search: (query, callback) =>
    @client.get(url: @options.api_root, params: { q: query }, callback: callback)

_.extend EntitySearchService::, Marbles.Events
_.extend EntitySearchService::, Marbles.Accessors

if (api_root = TentStatus.config.entity_search_api_root)
  TentStatus.services ?= {}
  TentStatus.services.entity_search = new EntitySearchService(api_root: api_root)

