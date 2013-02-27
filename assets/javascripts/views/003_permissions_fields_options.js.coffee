Marbles.Views.PermissionsFieldsOptions = class PermissionsFieldsOptionsView extends TentStatus.View
  @template_name: 'permissions_fields_options'
  @view_name: 'permissions_fields_options'

  constructor: (options = {}) ->
    super

    @on 'ready', @initOptions

    post = @parent_view.parent_view.parent_view.post?()
    if !post || post.get('permissions.public')
      @set 'options', [
        {
          text: 'Everyone'
          value: 'all'
          group: true
        }
      ]
    else
      options = []
      if post
        for m in post.postMentions()
          continue unless m.entity
          options.push {
            text: TentStatus.Helpers.minimalEntity(m.entity)
            value: m.entity
            group: false
          }
      @set 'options', options

    @on 'change:options', @render
    @render()

  initOptions: =>
    return unless @options
    option_els = Marbles.DOM.querySelectorAll('.option', @el)
    @option_views = for option, index in @options
      new OptionView parent_view: @, option: option, el: option_els[index]

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
    @options = options
    @trigger 'change:options'

  context: =>
    options: @options

class OptionView
  constructor: (params = {}) ->
    for k,v of params
      @[k] = v

    @elements = {
      remove: Marbles.DOM.querySelector('.remove', @el)
    }

    Marbles.DOM.on @elements.remove, 'click', @remove

  unmarkDelete: =>
    @marked_delete = false
    Marbles.DOM.removeClass(@elements.remove, 'active')

  markDelete: =>
    @marked_delete = true
    Marbles.DOM.removeClass(@elements.remove, 'active')

  remove: (e) =>
    e?.stopPropagation()
    @parent_view.removeOption(@option)

