TentStatus.Views.PermissionsFields = class PermissionsFieldsView extends TentStatus.View
  templateName: 'permissions_fields'

  initialize: (options = {}) ->
    @parentView = options.parentView
    super

    @on 'init:PermissionsFieldsPicker', @initPicker
    @on 'init:PermissionsFieldsOptions', @initOptions
    @render()

  optionsInclude: (option) =>
    @options_view.optionsInclude(option)

  initPicker: (@picker_view) =>
    @picker_view.initInput $('.picker-input', @el).get(0)

  initOptions: (@options_view) =>
    @bindEvents()
    @hide()

  bindEvents: =>
    @elements = {
      input_toggle: $('.permissions-options-container', @el).get(0)
      visibility_toggle: $('.show-option-picker', @el).get(0)
    }

    @text = {
      visibility_toggle: {
        show: $(@elements.visibility_toggle).attr('data-show-text')
        hide: $(@elements.visibility_toggle).attr('data-hide-text')
      }
    }

    $(@elements.input_toggle).on 'click', @focusInput

    @$el.on 'click', (e) =>
      return unless _.any($(e.target).parents(), (el) => el == @el)
      @focusInput()

    $(@elements.visibility_toggle).on 'click', (e) =>
      e.stopPropagation()
      @toggleVisibility()

  toggleVisibility: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    $(@options_view.el).hide()
    @picker_view?.hide()
    $(@elements.visibility_toggle).text(@text.visibility_toggle.show)

  show: =>
    @visible = true
    $(@options_view.el).show()
    $(@elements.visibility_toggle).text(@text.visibility_toggle.hide)
    @focusInput()

  addOption: (option) =>
    @options_view.addOption(option)

  removeOption: (option) =>
    @options_view.removeOption(option)

  render: =>
    html = super
    @$el.html(html)
    @trigger 'ready'

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

