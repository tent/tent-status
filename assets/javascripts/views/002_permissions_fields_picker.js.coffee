TentStatus.Views.PermissionsFieldsPicker = class PermissionsFieldsPickerView extends TentStatus.View
  @template_name: 'permissions_fields_picker'
  @view_name: 'permissions_fields_picker'

  constructor: (options = {}) ->
    super

    @option_views = []
    @on 'ready', @initOptions

    @parent_view.on 'change:picker_options', => @render(); @show()
    @hide()
    @render()

    DOM.on document, 'click', (e) =>
      unless (_.any DOM.parentNodes(e.target), (el) => el == @parent_view.el)
        @hide()

  initInput: (el) =>
    @input = new PickerInputView parent_view: @, el: el

  initOptions: =>
    for view in @option_views
      view.destroy()

    should_activate_first_option = true
    active_option_value = @option_views[@active_option]?.getValue()
    @active_option = null
    @option_views = []
    option_els = DOM.querySelectorAll('li.option', @el)
    for option, index in (@matches || [])
      el = option_els[index]
      view = new PickerOptionView parent_view: @, el: el, index: index
      @option_views.push(view)
      if view.getValue() == active_option_value
        should_activate_first_option = false
        view.setActive()

    if should_activate_first_option
      @active_option = -1
      @nextOption()

  nextOption: =>
    return unless @option_views.length
    index = @active_option
    index ?= 0
    @option_views[index]?.unsetActive()
    if index == @option_views.length-1
      index = 0
    else
      index += 1
    @option_views[index].setActive()

  prevOption: =>
    return unless @option_views.length
    index = @active_option
    index ?= @option_views.length-1
    @option_views[index]?.unsetActive()
    if index == 0
      index = @option_views.length-1
    else
      index -= 1
    @option_views[index].setActive()

  addActiveOption: =>
    return unless @option_views.length
    index = @active_option
    return unless @option_views[index]
    @option_views[index].add()
    return unless @option_views.length
    if index > @option_views.length-1
      @option_views[@option_views.length-1].setActive()
    else
      @option_views[index].setActive()

  displayMatches: (@matches) =>
    if !@matches.length && (q = @current_query?.replace(/^[\s\r\t\n]*/, '').replace(/[\s\r\t\n]*$/, '')) &&
       q.match(/^https?:\/\/[^.]+\..{2,}$/i) && !_.any(@parent_view.options_view.options, (o) => o.value == q)
      @matches.unshift({
        entity: q
        value: q
      })
    if !@matches.length && !@current_query?.match(/^[\s\r\t\n]*$/) && "Everyone".score(@current_query) &&
       !_.any(@parent_view.options_view.options, (o) => o.value == 'all')
      @matches.unshift({
        name: 'Everyone'
        value: 'all'
        group: true
      })

    return @hide() unless @matches.length
    @render()
    @show()

  fetchResults: (query) =>
    return if @current_query == query
    @current_query = query
    return @displayMatches([]) if query.match(/^[\s\r\t\n]*$/)
    matched_entities = {}
    matches = []
    complete = (results, nextPage) =>
      return unless @current_query == query
      results ?= []
      for result in results
        result.score = ((result.name || "").score(query) + result.entity.score(query))
        result.value = result.entity
        if result.score
          matches.push(result)
      matches = _.filter matches, (m) => m.score && !@parent_view.optionsInclude(m)
      matches = _.sortBy matches, (m) => m.score * -1
      @displayMatches(matches)

      if results.length && (matches.length < 3 || _.first(matches).score < 0.6)
        nextPage(complete)

    @fetchFollowings complete

  fetchProfile: (entity, callback) =>
    TentStatus.Models.Profile.fetch { entity: entity },
      success: (profile) =>
        callback(profile)

      error: =>
        callback()

  fetchProfiles: (results, callback) =>
    return callback() unless results.length

    _num_remaining = results.length
    complete = =>
      _num_remaining -= 1
      callback(results) if _num_remaining == 0

    for result, index in results
      do (result, index) =>
        @input.showLoading()
        @fetchProfile result.entity, (profile) =>
          @input.hideLoading()
          results[index].name = profile?.get('name')
          complete()

  fetchFollowings: (callback) =>
    params = {
      limit: TentStatus.config.PER_PAGE
    }

    nextPage = =>
      @input.showLoading()
      if params.before_id
        cache_key = "followings:#{params.before_id}:#{params.limit}"
        cache_options = {saveToLocalStorage: true}
      else
        cache_key = "followings:#{params.limit}"
        cache_options = {}

      TentStatus.Cache.get cache_key, (follows = []) =>
        params.before_id = id if id = _.last(follows)?.id
        @input.hideLoading()
        return callback(follows, nextPage) if follows.length

        @input.showLoading()

        followings_collection = new TentStatus.Collections.Followings
        followings_collection.fetch params, {
          success: (followings) =>
            @input.hideLoading()

            if id = _.last(followings)?.id
              params.before_id = id

            results = _.map followings, (follow) =>
              { entity: follow.entity, id: follow.id }

            @fetchProfiles results, (results) =>
              TentStatus.Cache.set cache_key, results, cache_options
              callback(results, nextPage)

          error: =>
            @input.hideLoading()
            callback()
        }

    nextPage()

  context: =>
    options: @matches
    query: @current_query

  hide: =>
    DOM.hide(@el.parentNode)

  show: =>
    DOM.show(@el.parentNode)

class PickerOptionView
  constructor: (params = {}) ->
    @[k] = v for k,v of params

    @permissions_fields_view = @parent_view.parent_view

    @elements = {}

    unless @is_input
      DOM.on @el, 'click', (e) =>
        e.stopPropagation()
        @add()
      DOM.on @el, 'mouseover', (e) =>
        @parent_view.option_views[@parent_view.active_option]?.unsetActive()
        @setActive(false)

  getOption: =>
    @parent_view.matches[@index]

  getValue: =>
    @getOption()?.value

  getText: =>
    @getOption().name || TentStatus.Helpers.minimalEntity(@getOption().value)

  isGroup: =>
    !!@getOption().group

  destroy: =>
    DOM.removeNode(@el) if @el

  scrollIntoView: =>
    offset = @el.offsetTop
    scrollY = @parent_view.el.scrollTop

    if offset < scrollY
      @parent_view.el.scrollTop = offset
    else if (offset + parseInt(DOM.getStyle(@el, 'height'))) > (scrollY + parseInt(DOM.getStyle(@parent_view.el, 'height')))
      @parent_view.el.scrollTop = offset - parseInt(DOM.getStyle(@parent_view.el, 'height')) + @el.offsetHeight

  setActive: (should_scroll = true) =>
    @active = true
    @parent_view.active_option = @index
    DOM.addClass(@el, 'active')

    @scrollIntoView() if should_scroll

  unsetActive: =>
    @active = false
    if @parent_view.active_option == @index
      @parent_view.active_option = null
    DOM.removeClass(@el, 'active')

  add: =>
    option = {
      text: @getText()
      value: @getValue()
      group: @isGroup()
    }
    @destroy()
    views = @parent_view.option_views
    @parent_view.option_views = views.slice(0, @index).concat(views.slice(@index+1, views.length))
    matches = @parent_view.matches
    @parent_view.matches = matches.slice(0, @index).concat(matches.slice(@index+1, matches.length))

    for view, index in @parent_view.option_views
      view.index = index

    @permissions_fields_view.addOption(option)

class PickerInputView extends PickerOptionView
  constructor: ->
    @is_input = true
    super
    @elements.input = DOM.querySelector('input[type=text]', @el)

    @elements.loading = DOM.querySelector('.loading', @el)
    @loading_view = new TentStatus.Views.LoadingIndicator el: @elements.loading

    @options_view = @parent_view.parent_view.options_view

    @_keydown_value = ''

    DOM.on @elements.input, 'keydown', (e) =>
      @calibrate(e)
      @_keydown_value = @elements.input.value
      switch e.keyCode
        when 13 # enter/return
          e.preventDefault()
          if !@parent_view.option_views.length && (e.ctrlKey || e.metaKey)
            @parent_view.parent_view.parent_view?.submit()
          else
            @parent_view.addActiveOption()
          false
        when 27 # escape
          e.preventDefault()
          @clear()
          @parent_view.hide()
          false
        when 38 # up arrow
          e.preventDefault()
          @parent_view.prevOption()
          false
        when 40 # down arrow
          e.preventDefault()
          @parent_view.nextOption()
          false

    DOM.on @elements.input, 'keyup', (e) =>
      @calibrate()
      clearTimeout @_fetch_timeout
      @_fetch_timeout = setTimeout (=> @parent_view.fetchResults(@elements.input.value)), 60

      if !@_keydown_value.length
        option_view = _.last(@options_view.option_views)
        if option_view
          if e.keyCode == 8 # backspace
            if option_view.marked_delete
              option_view.remove()
            else
              option_view.markDelete()
          else
            option_view.unmarkDelete()

  calibrate: (e) =>
    el = @elements.input
    value = el.value
    if e
      if e.keyCode == 8 # backspace
        value = value.substr(0, value.length-1)
      else if !e.ctrlKey && !e.metaKey && !e.altKey
        char = String.fromCharCode(e.keyCode)
        char = char.toLowerCase() unless e.shiftKey
        value += char

    padding = parseInt(DOM.getStyle(@el, 'padding-left')) + parseInt(DOM.getStyle(@el, 'padding-right'))
    max_width = DOM.innerWidth(@el.parentNode) - padding
    text_width = maxkir.CursorPosition.getTextMetrics(el, value, padding)[0]

    DOM.setStyles(el,
      width: Math.max(Math.min(text_width, max_width), 20).toString() + 'px'
    )

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
    @calibrate()

  focus: =>
    @calibrate()
    @elements.input.focus()

  focusAtEnd: =>
    @calibrate()
    selection = new DOM.InputSelection @elements.input
    end = @elements.input.value.length
    selection.setSelectionRange(end, end)

  showLoading: =>
    @_loading_requests ?= 0
    @_loading_requests += 1
    @loading_view.show() if @_loading_requests == 1

  hideLoading: =>
    @_loading_requests ?= 1
    @_loading_requests -= 1
    @loading_view.hide() if @_loading_requests == 0

