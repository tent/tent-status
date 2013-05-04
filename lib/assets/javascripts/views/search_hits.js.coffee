Marbles.Views.SearchHits = class SearchHitsView extends Marbles.View
  @view_name: 'search_hits'
  @template_name: 'search_hits'

  constructor: (options = {}) ->
    super

    options.parent_view.on 'init:SearchResults', (search_results_view) =>
      search_results_view.results_collection.once 'fetch:success', @fetchSuccess
      search_results_view.results_collection.once 'fetch:error', @fetchError

  fetchSuccess: (collection, res, xhr) =>
    @render(@context(res))

  fetchError: (collection, res, xhr) =>
    @render()

  context: (res = {}) =>
    total_hits: res.total_hits
    no_results: res.total_hits == 0
