TentStatus.Views.PermissionsFields = class PermissionsFieldsView extends TentStatus.View
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
    @picker_view.initInput DOM.querySelector('.picker-input', @el)
    @picker_view.input.clear()
    @picker_view.input.focusAtEnd() unless DOM.match(@parent_view.textarea, ':focus')

  initOptions: (@options_view) =>
    @options_view.on 'ready', => @initInput()

    @bindEvents()
    @hide()

  bindEvents: =>
    @elements = {
      input_toggle: DOM.querySelector('.permissions-options-container', @el)
      visibility_toggle: DOM.querySelector('.show-option-picker', @el)
    }

    @text = {
      visibility_toggle: {
        show: DOM.attr(@elements.visibility_toggle, 'data-show-text')
        hide: DOM.attr(@elements.visibility_toggle, 'data-hide-text')
      }
    }

    DOM.on(@elements.input_toggle, 'click', @focusInput)

    DOM.on @el, 'click', (e) =>
      return unless _.any(DOM.parentNodes(e.target), (el) => el == @el)
      @focusInput()

    DOM.on @elements.visibility_toggle, 'click', (e) =>
      e.stopPropagation()
      @toggleVisibility()

  toggleVisibility: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    DOM.hide(@options_view.el)
    @picker_view?.hide()
    @elements.visibility_toggle.innerText = @text.visibility_toggle.show

  show: (should_focus = true) =>
    @visible = true
    DOM.show(@options_view.el)
    @elements.visibility_toggle.innerText = @text.visibility_toggle.hide
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

