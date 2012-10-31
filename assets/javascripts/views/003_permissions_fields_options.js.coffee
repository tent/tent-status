TentStatus.Views.PermissionsFieldsOptions = class PermissionsFieldsOptionsView extends TentStatus.View
  templateName: 'permissions_fields_options'

  initialize: (options = {}) ->
    @parentView = options.parentView
    super

    @on 'ready', @initOptions

    @set 'options', [
      {
        text: 'Everyone'
        value: 'all'
        group: true
      }
    ]

    @on 'change:options', @render
    @render()

  initOptions: =>
    return unless @options
    option_els = $('.option', @el)
    @option_views = for option, index in @options
      new OptionView parentView: @, option: option, el: option_els[index]

  optionsInclude: (option) =>
    for item in @options
      return true if item.value == option.value
    false

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

class OptionView
  constructor: (params = {}) ->
    for k,v of params
      @[k] = v

    @elements = {
      remove: $('.remove', @el).get(0)
    }

    $(@elements.remove).on 'click', @remove

  remove: =>
    @parentView.removeOption(@option)
