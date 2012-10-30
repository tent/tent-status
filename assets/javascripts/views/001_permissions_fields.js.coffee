TentStatus.Views.PermissionsFields = class PermissionsFieldsView extends TentStatus.View
  templateName: 'permissions_fields'

  initialize: (options = {}) ->
    @parentView = options.parentView
    super

    @on 'ready', @initOptions

    @on 'change:options', @render
    @set 'options', [
      {
        text: 'Everyone'
        value: 'all'
        group: true
      }
    ]

  initOptions: =>
    return unless @options
    option_els = $('.option', @$el)
    @option_views = for option, index in @options
      new PermissionsFieldsOptionView parentView: @, option: option, el: option_els[index]

    @elements = {
      input_toggle: $('.permissions-options-container', @el).get(0)
    }

    @$el.on 'click', (e) =>
      return if e.target.parentNode.parentNode != @el && e.target.tagName != 'INPUT'
      @focusInput()

    $(@elements.input_toggle).on 'click', @focusInput

  addOption: (option) =>
    for item in @options
      return if item.value == option.value

    @options.push(option)
    @trigger 'change:options'

  removeOption: (option) =>
    options = []
    for item in @options
      continue if item.value == option.value
      options.push item
    @set 'options', options

  context: =>
    options: @options

  render: =>
    html = super
    @$el.html(html)
    @trigger 'ready'

  focusInput: =>
    return unless picker_view = @child_views.PermissionsFieldsPicker?[0]
    picker_view.input.focus()

class PermissionsFieldsOptionView
  constructor: (params = {}) ->
    for k,v of params
      @[k] = v

    @elements = {
      remove: $('.remove', @el).get(0)
    }

    $(@elements.remove).on 'click', @remove

  remove: =>
    @parentView.removeOption(@option)

