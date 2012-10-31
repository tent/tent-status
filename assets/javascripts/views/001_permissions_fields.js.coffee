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
    @elements = {
      input_toggle: $('.permissions-options-container', @el).get(0)
    }

    $(@elements.input_toggle).on 'click', @focusInput

    @$el.on 'click', (e) =>
      return unless _.any($(e.target).parents(), (el) => el == @el)
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

