Marbles.Views.PermissionsFields = class PermissionsFieldsView extends Marbles.View
  @template_name: 'permissions_fields'
  @view_name: 'permissions_fields'

  constructor: (options = {}) ->
    super

    @on 'init:PermissionsFieldsPicker', @initPicker
    @on 'init:PermissionsFieldsOptions', @initOptions
    @render()

    setImmediate @subscribeToMentions

  mentionsView: =>
    unless @mentions_view_cid && mentions_view = Marbles.View.find(cid: @mentions_view_cid)
      return unless mentions_container_view = @findSiblingViews('MentionsAutoCompleteTextareaContainer')?[0]
      return unless mentions_view = mentions_container_view.childViews('MentionsAutoCompleteTextarea')?[0]
      @mentions_view_cid = mentions_view.cid
    mentions_view

  subscribeToMentions: =>
    return unless mentions_view = @mentionsView()
    return unless mentions_manager = mentions_view.inline_mentions_manager

    mentions_manager.on 'change:inline_mentions', @inlineMentionsChanged

  inlineMentionsChanged: (inline_mentions) =>
    mentions_view = @mentionsView()

    mentions_view.setCursorPosition()

    for entity, items of inline_mentions
      continue unless items.length
      @options_view.addOption(
        value: entity
        text: items[0].display_text
        group: false
      )
      mentions_view.focus()

  optionsInclude: (option) =>
    @options_view.optionsInclude(option)

  initPicker: (@picker_view) =>
    @initInput()

  initInput: =>
    value = @picker_view.input?.getValue() || ''
    @picker_view.initInput Marbles.DOM.querySelector('.picker-input', @el)
    @picker_view.input.clear()
    @picker_view.input.focusAtEnd() unless Marbles.DOM.match(@parentView().textarea, ':focus')

  initOptions: (@options_view) =>
    @options_view.on 'ready', (=> @initInput()), @
    @options_view.on 'change:options', => @trigger('change:options', arguments...)

    @bindEvents()
    @hide()

  bindEvents: =>
    @elements = {
      input_toggle: Marbles.DOM.querySelector('.permissions-options-container', @el)
    }

    Marbles.DOM.on(@elements.input_toggle, 'click', @focusInput)

    Marbles.DOM.on @el, 'click', (e) =>
      return unless _.any(Marbles.DOM.parentNodes(e.target), (el) => el == @el)
      @focusInput()

  hide: =>
    @visible = false
    Marbles.DOM.hide(@options_view.el)
    @picker_view?.hide()

  show: (should_focus = true) =>
    @visible = true
    Marbles.DOM.show(@options_view.el)
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
      entities: []
    }
    for option in @options_view.options
      return { public: true } if option.value == 'all'
      data.entities.push(option.value)
    data

