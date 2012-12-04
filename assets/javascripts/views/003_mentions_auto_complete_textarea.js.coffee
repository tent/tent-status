TentStatus.Views.MentionsAutoCompleteTextarea = class MentionsAutoCompleteTextareaView extends TentStatus.View
  @template_name: 'mentions_autocomplete_textarea'
  @view_name: 'mentions_autocomplete_textarea'

  constructor: (options = {}) ->
    super

    @parent_view.on 'init:PermissionsFields', (view) =>
      for entity in @getReplyToEntities()
        view.addOption(
          text: TentStatus.Helpers.minimalEntity(entity)
          value: entity
          group: false
        )

    @on 'init:PermissionsFieldsPicker', @initPickerView
    @on 'ready', @initAutoComplete

    @options_view = {
      options: []
    }

    @render()

  initPickerView: (@picker_view) =>
    @textarea_view = @picker_view.input = new TextareaView(
      parent_view: @
      el: @textarea = DOM.querySelector('textarea', @el)
      picker_view: @picker_view
    )

  optionsInclude: => false

  addOption: (option) =>
    @textarea_view.addOption(option)
    if permissions_fields_view = TentStatus.View.instances.all[@parent_view._child_views.PermissionsFields?[0]]
      permissions_fields_view.addOption(option)
      permissions_fields_view.show(false)

  getReplyToEntities: =>
    return [] unless @parent_view.is_reply_form

    post = @parent_view.parent_view.post
    return [] unless post

    post = post.get('repost') if @parent_view.is_repost
    return [] unless post

    TentStatus.Views.Post::getReplyToEntities(post, false)

  context: =>
    return {} unless @parent_view.is_reply_form
    @parent_view.context()

class TextareaView
  constructor: (params = {}) ->
    @[k] = v for k,v of params

    @elements = {
      loading: DOM.querySelector('.loading', @parent_view.el)
    }
    @loading_view = new TentStatus.Views.LoadingIndicator el: @elements.loading

    DOM.on @el, 'keydown', (e) =>
      switch e.keyCode
        when 13 # enter/return
          return unless @enabled
          e.preventDefault()
          @picker_view.addActiveOption()
          false
        when 8 # backspace
          if @enabled
            pos = (new DOM.InputSelection @el).start
            @close() if @selection and pos <= @selection.start
        when 27 # escape
          return unless @enabled
          e.preventDefault()
          @close()
          false
        when 38 # up arrow
          return unless @enabled
          e.preventDefault()
          @picker_view.prevOption()
          false
        when 40 # down arrow
          return unless @enabled
          e.preventDefault()
          @picker_view.nextOption()
          false
        when 32 # space
          @close()

    DOM.on @el, 'keyup', (e) =>
      clearTimeout @_fetch_timeout
      if e.shiftKey && e.keyCode == 54 # carret (^)
        return @open()

      return unless @enabled
      @setPickerPosition()
      @_fetch_timeout = setTimeout (=> @picker_view.fetchResults(@selectionValue())), 60

  setPickerPosition: =>
    cp = new maxkir.CursorPosition(@el, parseInt(DOM.getStyle(@el, 'padding')))
    coordinates = cp.getPixelCoordinates()
    start_coordinates = maxkir.CursorPosition.getTextMetrics(@el, @selectionValue(), parseInt(DOM.getStyle(@el, 'padding')))

    [left, top] = coordinates
    left -= start_coordinates[0]
    picker_width = @picker_view.el.parentNode.offsetWidth
    right_bound = parseInt DOM.getStyle(@el, 'width')

    css = {
      position: 'absolute'
      top: top
    }

    if (left + picker_width) > right_bound
      css.left = right_bound - picker_width
    else
      css.left = left

    DOM.setStyles(@picker_view.el.parentNode, css)


  selectionValue: =>
    value = @el.value
    value.substr(@selection.start, value.length).match(/^([^\s\r\t\n]+)/)?[1] || ''

  addOption: (option) =>
    end_selection = new DOM.InputSelection @el
    entity = option.value + ' '
    value = @el.value
    @el.value = TentStatus.Helpers.replaceIndexRange(@selection.start, end_selection.end, value, entity)

    end = @selection.start + entity.length
    @selection.setSelectionRange(end, end)
    @close()

  open: =>
    @enabled = true
    @picker_view.show()
    @selection = new DOM.InputSelection @el

  close: =>
    @enabled = false
    @picker_view.hide()
    delete @selection

  showLoading: =>
    @_loading_requests ?= 0
    @_loading_requests += 1
    @loading_view.show() if @_loading_requests == 1

  hideLoading: =>
    @_loading_requests ?= 1
    @_loading_requests -= 1
    @loading_view.hide() if @_loading_requests == 0

