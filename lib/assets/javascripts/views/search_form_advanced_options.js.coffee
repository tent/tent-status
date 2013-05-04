Marbles.Views.SearchFormAdvancedOptions = class SearchFormAdvancedOptionsView extends Marbles.View
  @view_name: 'search_form_advanced_options'
  @template_name: 'search_form_advanced_options'

  constructor: (options = {}) ->
    super

    @on 'ready', @loadFormParams
    @on 'ready', =>
      return unless @get('auto_focus')
      Marbles.DOM.querySelector('input', @el)?.focus()

  loadFormParams: =>
    return unless @visible
    Marbles.DOM.loadFormParams(@el, @parentView().params)

  context: =>
    visible: @visible
