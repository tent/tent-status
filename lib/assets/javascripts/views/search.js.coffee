Marbles.Views.Search = class SearchView extends Marbles.View
  @view_name: 'search'
  @template_name: 'search'

  constructor: (options = {}) ->
    super
    @params = options.params

    setImmediate @render

