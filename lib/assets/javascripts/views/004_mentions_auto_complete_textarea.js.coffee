Marbles.Views.MentionsAutoCompleteTextarea = class MentionsAutoCompleteTextareaView extends Marbles.View
  @view_name: 'mentions_autocomplete_textarea'

  constructor: (options = {}) ->
    super

    @render()

    @parentFormView()?.on 'init:PermissionsFields', (view) =>
      for entity in @conversationEntities()
        view.addOption(
          text: TentStatus.Helpers.minimalEntity(entity)
          value: entity
          group: false
        )
    , @

    options.parent_view.on 'init:PermissionsFieldsPicker', @initPickerView

    @elements = {
      loading: Marbles.DOM.querySelector('.loading', options.parent_view.el)
    }
    @loading_view = new Marbles.Views.LoadingIndicator el: @elements.loading

    @bindEvents()

  parentFormView: =>
    if view = Marbles.View.find(@_parent_form_view_cid)
      return view

    if view = @findParentView('new_post_form') || @findParentView('post_reply_form') || @findParentView('edit_post')
      @_parent_form_view_cid = view.cid
      return view

  conversationEntities: =>
    return [] unless parent_form_view = @parentFormView()

    if parent_form_view.is_reply_form
      post = parent_form_view.post()
      return [] unless post
      post.get('conversation_entities')
    else
      if (parent_profile_view = @findParentView('profile')) && (profile = parent_profile_view.profile()) && !TentStatus.Helpers.isCurrentUserEntity(profile.get('entity'))
        [profile.get('entity')]
      else
        []

  context: =>
    return {} unless parent_form_view = @parentFormView()
    _.extend parent_form_view.context(),
      is_edit_form: parent_form_view.constructor.is_edit_form
      formatted:
        reply_to_entities: _.map( @conversationEntities(), (entity) => TentStatus.Helpers.minimalEntity(entity) )

  # Generate content to be rendered in textarea
  renderHTML: (context = @context()) =>
    if context.is_edit_form
      context.post.content
    else
      _.map( context.formatted?.reply_to_entities || [], (i) -> "^#{i} " ).join("")

  initPickerView: (picker_view) =>
    @picker_view_cid = picker_view.cid

  optionsInclude: (option) =>
    for mention in TentStatus.Helpers.extractMentionsWithIndices(@el.value)
      return true if option.entity == mention.entity
    false

  pickerView: =>
    Marbles.View.find(@picker_view_cid)

  bindEvents: =>
    Marbles.DOM.on @el, 'keydown', (e) =>
      switch e.keyCode
        when 13 # enter/return
          return unless @enabled
          e.preventDefault()
          @pickerView()?.addActiveOption()
          false
        when 8 # backspace
          if @enabled
            pos = (new Marbles.DOM.InputSelection @el).start
            @close() if @selection and pos <= @selection.start
          else
            pos = (new Marbles.DOM.InputSelection @el).start
            old_value = @el.value.slice(0, pos)
            new_value = @el.value.slice(0, pos-1)

            if m = new_value.match(/\^\[([^\]]+)\]\(([^\)]+)\)$/)
              # backspacing the char before the end of mention markdown selects the whole mention
              selection = new Marbles.DOM.InputSelection @el
              @once 'keyup', =>
                start = m.index
                end = m.index + m[0].length
                if @el.value.slice(0, end) == new_value
                  selection.setSelectionRange(start, end)
            else if m = old_value.match(/\^\[(\S*?)$/)
              # backspacing any char within mention markdown removes the markdown and reopens autocomplete for remaining display text

              start = m.index
              m = @el.value.slice(start, @el.value.length).match(/^\^(\S+)/) # get the full markdown mention (will always match)
              end = start + m[0].length

              display_text_start = m[0].indexOf("[") + 1 + start
              display_text_end = m[0].indexOf("]") + start
              cursor_position = (new Marbles.DOM.InputSelection @el).start-1

              if cursor_position in [display_text_start...display_text_end]
                # editing display text
              else
                console.warn('TODO: remove mention')

                display_text = @el.value.slice(display_text_start, display_text_end)
                @once 'keyup', =>
                  return unless @el.value.slice(0, cursor_position) == new_value
                  selection = new Marbles.DOM.InputSelection @el
                  @el.value = TentStatus.Helpers.replaceIndexRange(start, cursor_position, @el.value, "^#{display_text}")
                  new_end = start + display_text.length + 1
                  selection.setSelectionRange(new_end, new_end)

                  @open()
                  selection.start = start + 1
                  selection.end = start + 1
                  @selection = selection
                  @fetchResults()

            else if (start = old_value.length-1) && old_value[old_value.length-1] == "^" && (m = @el.value.slice(start, @el.value.length).match(/^\^(\S+)/))
              # "^" removed so remove the full mention
              end = start + m[0].length
              selection = new Marbles.DOM.InputSelection @el
              selection.setSelectionRange(start, end)

        when 27 # escape
          return unless @enabled
          e.preventDefault()
          @close()
          false
        when 38 # up arrow
          return unless @enabled
          e.preventDefault()
          @pickerView()?.prevOption()
          false
        when 40 # down arrow
          return unless @enabled
          e.preventDefault()
          @pickerView()?.nextOption()
          false
        when 32 # space
          return unless @enabled
          e.preventDefault()
          @pickerView()?.addActiveOption()
          false

    Marbles.DOM.on @el, 'keyup', (e) =>
      @trigger('keyup', e)

      clearTimeout @_fetch_timeout
      if e.shiftKey && e.keyCode == 54 # carret (^)
        return @open()

      return unless @enabled
      @setPickerPosition()
      @fetchResults()

  fetchResults: =>
    clearTimeout @_fetch_timeout
    @_fetch_timeout = setTimeout (=>
      @pickerView()?.current_query = ''
      @pickerView()?.fetchResults(@selectionValue())
    ), 60

  focus: =>
    selection = new Marbles.DOM.InputSelection @el
    selection.setSelectionRange(@el.value.length, @el.value.length)

  setPickerPosition: =>
    cp = new maxkir.CursorPosition(@el, parseInt(Marbles.DOM.getStyle(@el, 'padding')))
    coordinates = cp.getPixelCoordinates()
    start_coordinates = maxkir.CursorPosition.getTextMetrics(@el, @selectionValue(), parseInt(Marbles.DOM.getStyle(@el, 'padding')))

    [left, top] = coordinates
    left -= start_coordinates[0]
    picker_width = @pickerView()?.el.parentNode.offsetWidth
    right_bound = parseInt Marbles.DOM.getStyle(@el, 'width')

    css = {
      position: 'absolute'
      top: top
    }

    if (left + picker_width) > right_bound
      css.left = right_bound - picker_width
    else
      css.left = left

    Marbles.DOM.setStyles(@pickerView()?.el.parentNode, css)

  selectionValue: =>
    value = @el.value
    value.substr(@selection.start, value.length).match(/^([^\s\r\t\n]+)/)?[1] || ''

  addOption: (option) =>
    end_selection = new Marbles.DOM.InputSelection @el
    mention_index = 0 # TODO: make this mean something
    markdown = "[#{option.text}](#{mention_index}) "
    value = @el.value
    @el.value = TentStatus.Helpers.replaceIndexRange(@selection.start, end_selection.end, value, markdown)

    end = @selection.start + markdown.length
    @selection.setSelectionRange(end, end)
    @close()

    console.warn("TODO: add mention")

    # TODO: refactor
    if permissions_fields_view = Marbles.View.instances.all[@parentFormView()?._child_views.PermissionsFields?[0]]
      selection = new Marbles.DOM.InputSelection @el

      permissions_fields_view.addOption(option)
      permissions_fields_view.show(false)

      # prevent permissions fields from hijacking cusor focus
      selection.setSelectionRange(selection.start, selection.end)

  open: =>
    @enabled = true
    if picker_view = @pickerView()
      picker_view.matches = []
      picker_view.render()
      picker_view.show()
    @selection = new Marbles.DOM.InputSelection @el

  close: =>
    @enabled = false
    @pickerView()?.hide()
    delete @selection

  showLoading: =>
    @_loading_requests ?= 0
    @_loading_requests += 1
    @loading_view.show() if @_loading_requests == 1

  hideLoading: =>
    @_loading_requests ?= 1
    @_loading_requests -= 1
    @loading_view.hide() if @_loading_requests == 0

