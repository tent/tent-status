Marbles.Views.SearchFetchPool = class SearchFetchPoolView extends TentStatus.View
  @view_name: 'search_fetch_pool'
  @template_name: 'fetch_posts_pool'

  constructor: (options = {}) ->
    super

    @on 'ready', @bindLink

    @fetch_interval = new TentStatus.FetchInterval fetch_callback: @fetchResults
    options.parent_view.on 'init-view', (view_class_name, view) =>
      switch view_class_name
        when 'SearchResults'
          @initSearchResultsView(view)
        when 'SearchHits'
          @initSearchHitsView(view)

    @initSearchHitsView(_.last(options.parent_view.childViews('SearchHits') || []))

  initSearchHitsView: (hits_view) =>
    @hits_view_cid = hits_view.cid

  initSearchResultsView: (results_feed_view) =>
    @results_feed_view_cid = results_feed_view.cid
    results_collection = results_feed_view.results_collection
    results_collection.on 'reset', =>
      @results_collection = new TentStatus.Collections.SearchResults api_root: results_collection.api_root
      @latest_published_at = (results_collection.first()?.get('published_at') || ((new Date * 1)/1000))
      @params = results_feed_view.params
      @fetch_interval.start()

  updateHits: (res) =>
    return unless hits_view = Marbles.View.find(@hits_view_cid)
    return unless results_feed_view = Marbles.View.find(@results_feed_view_cid)
    hits_view.render(hits_view.context(total_hits: results_feed_view.total_hits + res.total_hits))

  fetchResults: =>
    return if @frozen

    params = _.extend {}, @params, {
      since_time: @latest_published_at
    }
    delete params.max_time

    options = { success: @fetchSuccess, error: @fetchError, prepend: true }
    @results_collection.fetch(params,  options)

  fetchSuccess: (results, res) =>
    if results.length
      @fetch_interval.reset()
      @latest_published_at = Math.max(_.map(results, (r) -> r.get('published_at'))...)
      @updateHits(res)
      @render()
    else
      @fetch_interval.increaseDelay()

    @frozen = false

  fetchError: =>
    @fetch_interval.increaseDelay()
    @frozen = false

  emptyPool: =>
    results_feed_view = Marbles.View.find(@results_feed_view_cid)
    return unless results_feed_view

    last_result_cid = _.last(@results_collection.model_ids)

    results_feed_view.prependRender(@results_collection.models())
    results_feed_view.results_collection.prependIds(@results_collection.model_ids)
    @results_collection.empty()

    @render()

    if last_result_el = Marbles.DOM.querySelector("[data-post_cid='#{last_result_cid}']", results_feed_view.el)
      resultition = last_result_el.offsetTop - 20 # 20 is an arbitrary padding amount
      window.scrollTo(window.scrollX, resultition)

  context: =>
    posts_count: @results_collection.model_ids.length

  bindLink: =>
    link_element = Marbles.DOM.querySelector('.fetch-posts-pool', @el)
    Marbles.DOM.on link_element, 'click', (e) =>
      e.preventDefault()
      @emptyPool()

  render: =>
    context = @context()
    super(context)

    if context.posts_count
      TentStatus.setPageTitle prefix: "(#{context.posts_count})"
    else
      TentStatus.setPageTitle prefix: null

