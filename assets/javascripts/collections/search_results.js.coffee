TentStatus.Collections.SearchResults = class SearchResultsCollection extends Marbles.Collection
  @model: TentStatus.Models.SearchResult

  @buildModel: (attrs) ->
    @model.find(
      id: attrs.id
      fetch: false
    ) || new @model(attrs)

  constructor: (options = {}) ->
    @api_root = options.api_root
    throw new Error("#{@constructor.name} requires options.api_root!") unless @api_root

    super

  fetch: (params = {}, options = {}) =>
    client = new Marbles.HTTP.Client hosts: [@api_root], middleware: [Marbles.HTTP.Client.Middleware.SerializeJSON]
    client.get "/", @searchParams(params),
      success: (res, xhr) =>
        results = res.results || []
        models = if options.append
          @appendRaw(results)
        else if options.prepend
          @prependRaw(results)
        else
          @resetRaw(results)

        options.success?(models, xhr)
        @trigger('fetch:success', @, res, xhr)

      error: (res, xhr) =>
        options.error?(res, xhr)
        @trigger('fetch:failed', @, res, xhr)

  searchParams: (params = {}) =>
    _params = {
      text: params.q || ''
    }
    _params.entity = params.entity if params.entity
    _params.types = params.types || TentStatus.config.post_types
    _params

