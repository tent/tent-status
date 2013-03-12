Marbles.Views.SearchResults = class SearchResultsView extends TentStatus.View
  @view_name: 'search_results'
  @template_name: 'search_results'
  @partial_names: ['_post'].concat(Marbles.Views.Post.partial_names)

  constructor: (options = {}) ->
    super

    @params = options.parent_view.params
    @results_collection = new TentStatus.Collections.SearchResults api_root: TentStatus.config.search_api_root

    @results_collection.on 'reset', (models) => @render(@context(models)); @pagination_frozen = false
    @results_collection.on 'append:complete', @appendRender
    @results_collection.on 'prepend:complete', @prependRender

    @once 'ready', @initAutoPaginate

    # fire click event for first post view in feed (caught by author info view)
    @once 'ready', =>
      first_post_view = @childViews('Post')?[0]
      if first_post_view
        setImmediate => first_post_view.constructor.trigger('click', first_post_view)

    setImmediate => @fetch(@params)

  fetch: (params, options = {}) =>
    # hide author info
    Marbles.Views.Post.trigger('click', null)

    return unless params.q

    @pagination_frozen = true
    TentStatus.trigger('loading:start')

    @results_collection.fetch params, _.extend(
      success: (models, res, xhr) =>
        @total_hits = res.total_hits

      error: (res, xhr) =>
        @total_hits = 0

      complete: => TentStatus.trigger('loading:stop')
    , options)

  nextPage: =>
    @pagination_frozen = true

    first_result = @results_collection.first()

    # no results
    return @last_page = true unless first_result

    offset = @results_collection.model_ids.length
    start_time = first_result.get('published_at')

    # on last page
    if offset >= @total_hits
      return @last_page = true

    params = _.extend({}, @params, t: start_time, offset: offset)
    @fetch(params, append: true)

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

  initAutoPaginate: =>
    TentStatus.on 'window:scroll', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    return if @pagination_frozen || @last_page
    last_post = Marbles.DOM.querySelector('li.post:last-of-type', @el)
    return unless last_post
    last_post_offset_top = last_post.offsetTop || 0
    last_post_offset_top += last_post.offsetHeight || 0
    bottom_position = window.scrollY + Marbles.DOM.windowHeight()

    if last_post_offset_top <= bottom_position
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @nextPage, 0 unless @last_page

