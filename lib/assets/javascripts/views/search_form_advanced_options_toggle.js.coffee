Marbles.Views.SearchFormAdvancedOptionsToggle = class SearchFormAdvancedOptionsToggleView extends TentStatus.View
  @view_name: 'search_form_advanced_options_toggle'
  @template_name: 'search_form_advanced_options_toggle'

  constructor: (options = {}) ->
    super

    Marbles.DOM.on @el, 'click', => @toggle()

    @render()

    setImmediate =>
      if options.parent_view.show_advanced_options
        @toggle(auto_focus: false)
        options.parent_view.focus()

  advancedOptionsView: =>
    _.last(@parentView()?.childViews('SearchFormAdvancedOptions'))

  toggle: (options = { auto_focus: true }) =>
    view = @advancedOptionsView()
    return unless view
    @visible = !@visible

    if @visible
      Marbles.DOM.addClass(@el, 'visible')
    else
      Marbles.DOM.removeClass(@el, 'visible')

    view.set('visible', @visible)
    view.set('auto_focus', options.auto_focus)
    view.render()
    @parentView()?.focus() if not(@visible)
    @render()

  context: =>
    visible: @visible
