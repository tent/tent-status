TentStatus.Views.MentionsAutoCompleteTextarea = class MentionsAutoCompleteTextareaView extends TentStatus.View
  templateName: 'mentions_autocomplete_textarea'
  initialize: (options = {}) ->
    @parentView = options.parentView

    if @parentView.is_reply_form
      @templateName = 'reply_form_autocomplete_textarea'

      @parentView.on 'init:PermissionsFields', (view) =>
        for entity in @getReplyToEntities()
          view.addOption(
            text: TentStatus.Helpers.minimalEntity(entity)
            value: entity
            group: false
          )

    super

    @on 'init:PermissionsFieldsPicker', @initPickerView
    @on 'ready', @initAutoComplete

    @options_view = {
      options: []
    }

    @render()

  initPickerView: (@picker_view) =>
    @textarea_view = @picker_view.input = new TextareaView(
      parentView: @
      el: @textarea = $('textarea', @el).get(0)
      picker_view: @picker_view
    )

  optionsInclude: => false

  addOption: (option) =>
    @textarea_view.addOption(option)
    if permissions_fields_view = @parentView.child_views.PermissionsFields?[0]
      permissions_fields_view.addOption(option)
      permissions_fields_view.show(false)

  getReplyToEntities: =>
    return [] unless @parentView.is_reply_form

    post = @parentView.parentView.post
    return [] unless post

    post = post.get('repost') if @parentView.is_repost
    return [] unless post

    TentStatus.Views.Post::getReplyToEntities(post, false)

  context: =>
    return {} unless @parentView.is_reply_form
    @parentView.context()

  render: =>
    return unless html = super
    @$el.html(html)
    @trigger 'ready'

class TextareaView
  constructor: (params = {}) ->
    @[k] = v for k,v of params

    $(@el).on 'keydown', (e) =>
      switch e.keyCode
        when 13 # enter/return
          return unless @enabled
          e.preventDefault()
          @picker_view.addActiveOption()
          false
        when 8 # backspace
          if @enabled
            pos = (new DOM.InputSelection @el).start
            @close() if pos <= @selection.start
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

    $(@el).on 'keyup', (e) =>
      clearTimeout @_fetch_timeout
      if e.keyCode == 54 # carret (^)
        return @open()

      return unless @enabled
      @setPickerPosition()
      @_fetch_timeout = setTimeout (=> @picker_view.fetchResults(@selectionValue())), 60

  setPickerPosition: =>
    cp = new maxkir.CursorPosition(@el, parseInt($(@el).css('padding')))
    coordinates = cp.getPixelCoordinates()
    start_coordinates = maxkir.CursorPosition.getTextMetrics(@el, @selectionValue(), parseInt($(@el).css('padding')))

    [left, top] = coordinates
    left -= start_coordinates[0]
    picker_width = $(@picker_view.el.parentNode).outerWidth()
    right_bound = $(@el).innerWidth()

    css = {
      position: 'absolute'
      top: top
    }

    if (left + picker_width) > right_bound
      css.left = right_bound - picker_width
    else
      css.left = left

    $(@picker_view.el.parentNode).css(css)


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

  hideLoading: =>

