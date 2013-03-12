Marbles.Views.SearchForm = class SearchFormView extends TentStatus.View
  @view_name: 'search_form'
  @template_name: 'search_form'

  constructor: (options = {}) ->
    super
    @params = options.parent_view.params

    setImmediate @render

