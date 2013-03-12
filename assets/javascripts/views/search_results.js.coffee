Marbles.Views.SearchResults = class SearchResultsView extends TentStatus.View
  @view_name: 'search_results'
  @template_name: 'search_results'
  @partial_names: ['_post'].concat(Marbles.Views.Post.partial_names)

  constructor: (options = {}) ->
    super

    @params = options.parent_view.params
    @results_collection = new TentStatus.Collections.SearchResults api_root: TentStatus.config.search_api_root

    @results_collection.on 'reset', (models) => @render(@context(models))
    @results_collection.on 'append:complete', @appendRender
    @results_collection.on 'prepend:complete', @prependRender

    @fetch(@params)

  fetch: (params) =>
    @pagination_frozen = true
    TentStatus.trigger('loading:start')

    @results_collection.fetch(params, complete: => TentStatus.trigger('loading:stop'))

  context: (models) =>
    results: _.map(models, (model) => @postContext(model))
    is_search_results: true

  postContext: (model) =>
    Marbles.Views.Post::context(model.post())

  appendRender: (models) =>
    html = ""
    for model in models
      html += @constructor.partials['_post'].render(@postContext(model), @constructor.partials)

    Marbles.DOM.appendHTML(@el, html)
    @bindViews()
    @pagination_frozen = false

  prependRender: (models) =>
    html = ""
    for model in models
      html += @constructor.partials['_post'].render(@postContext(model), @constructor.partials)

    Marbles.DOM.prependHTML(@el, html)
    @bindViews()

