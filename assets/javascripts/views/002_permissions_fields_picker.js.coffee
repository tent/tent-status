TentStatus.Views.PermissionsFieldsPicker = class PermissionsFieldsPickerView extends TentStatus.View
  templateName: 'permissions_fields_picker'

  initialize: (options = {}) ->
    @parentView = options.parentView
    super

    @on 'ready', @initOptions

    @parentView.on 'change:picker_options', => @render(); @show()
    @hide()
    @render()

  initOptions: =>
    @input = new PickerInputView parentView: @, el: $('li.option.input', @el).get(0)

  context: =>
    options: @parentView.picker_options

  render: =>
    html = super
    @$el.html(html)
    @trigger 'ready'

  hide: =>
    $(@el).hide()

  show: =>
    $(@el).show()

class PickerOptionView
  constructor: (params = {}) ->
    @[k] = v for k,v of params

    @permissions_fields_view = @parentView.parentView

    @elements = {}

    unless @is_input
      $(@el).on 'click', @add

  getValue: => @value

  getText: =>
    @getValue().replace(/^https?:\/\/(?:www\.)?/, '')

  isGroup: =>
    @getValue() == 'all'

  add: =>
    @permissions_fields_view.addOption {
      text: @getText()
      value: @getValue()
      group: @isGroup()
    }

class PickerInputView extends PickerOptionView
  constructor: ->
    @is_input = true
    super
    @elements.input = $('input[type=text]', @el).get(0)

    $(@elements.input).on 'keydown', (e) =>
      if e.keyCode == 13
        e.preventDefault()
        @add()
        false
      else if e.keyCode == 27
        e.preventDefault()
        @clear()
        @parentView.hide()
        false

  getValue: =>
    value = @elements.input.value
    value = 'all' if value.toLowerCase() == 'everyone'
    value.replace(/^[\s\r\t\n]*/, '').replace(/[\s\r\t\n]*$/, '')

  getText: =>
    value = @getValue()
    if value == 'all'
      'Everyone'
    else
      super

  add: =>
    return unless @getValue().match(/^https?:\/\/[^.]+\.\S+$/i)
    super

  clear: =>
    @elements.input.value = ''

  focus: =>
    @parentView.show()
    $(@elements.input).focus()

