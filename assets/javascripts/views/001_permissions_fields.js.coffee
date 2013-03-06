Marbles.Views.PermissionsFields = class PermissionsFieldsView extends TentStatus.View
  @template_name: 'permissions_fields'
  @view_name: 'permissions_fields'

  constructor: (options = {}) ->
    super

    @on 'init:PermissionsFieldsPicker', @initPicker
    @on 'init:PermissionsFieldsOptions', @initOptions
    @render()

  optionsInclude: (option) =>
    @options_view.optionsInclude(option)

  initPicker: (@picker_view) =>
    @initInput()

  initInput: =>
    value = @picker_view.input?.getValue() || ''
    @picker_view.initInput Marbles.DOM.querySelector('.picker-input', @el)
    @picker_view.input.clear()
    @picker_view.input.focusAtEnd() unless Marbles.DOM.match(@parent_view.textarea, ':focus')

  initOptions: (@options_view) =>
    @options_view.on 'ready', (=> @initInput()), @

    @bindEvents()
    @hide()

  bindEvents: =>
    @elements = {
      input_toggle: Marbles.DOM.querySelector('.permissions-options-container', @el)
      visibility_toggle: Marbles.DOM.querySelector('.show-option-picker', @el)
    }

    @text = {
      visibility_toggle: {
        show: Marbles.DOM.attr(@elements.visibility_toggle, 'data-show-text')
        hide: Marbles.DOM.attr(@elements.visibility_toggle, 'data-hide-text')
      }
    }

    Marbles.DOM.on(@elements.input_toggle, 'click', @focusInput)

    Marbles.DOM.on @el, 'click', (e) =>
      return unless _.any(Marbles.DOM.parentNodes(e.target), (el) => el == @el)
      @focusInput()

    Marbles.DOM.on @elements.visibility_toggle, 'click', (e) =>
      e.stopPropagation()
      @toggleVisibility()

  toggleVisibility: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    Marbles.DOM.hide(@options_view.el)
    @picker_view?.hide()
    #Marbles.DOM.setInnerText(@elements.visibility_toggle, @text.visibility_toggle.show)

  show: (should_focus = true) =>
    @visible = true
    Marbles.DOM.show(@options_view.el)
    #Marbles.DOM.setInnerText(@elements.visibility_toggle, @text.visibility_toggle.hide)
    @focusInput() if should_focus

  addOption: (option) =>
    @options_view.addOption(option)

  removeOption: (option) =>
    @options_view.removeOption(option)

  focusInput: =>
    @picker_view.input.focus()

  buildPermissions: =>
    data = {
      public: false
      entities: {}
    }
    for option in @options_view.options
      return { public: true } if option.value == 'all'
      data.entities[option.value] = true
    data

