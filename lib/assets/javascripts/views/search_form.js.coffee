Marbles.Views.SearchForm = class SearchFormView extends TentStatus.View
  @view_name: 'search_form'
  @template_name: 'search_form'

  constructor: (options = {}) ->
    super
    @params = options.parent_view.params

    @show_advanced_options = !!@params.entity

    @on 'ready', @loadFormParams
    @on 'ready', @focus

    Marbles.DOM.on @el, 'submit', (e) =>
      e.preventDefault()
      @submit()
      return false

    @render()

  submit: =>
    params = Marbles.DOM.serializeForm(@el)
    query_string = Marbles.history.serializeParams(params)

    return unless query_string

    TentStatus.Routers.search.navigate("/search#{query_string}", {trigger: true})

  focus: =>
    Marbles.DOM.querySelector('[name=q]', @el)?.focus()

  loadFormParams: =>
    Marbles.DOM.loadFormParams(@el, @params)

  context: =>
    params: @params

