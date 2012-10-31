TentStatus.Views.PermissionsFieldsPicker = class PermissionsFieldsPickerView extends TentStatus.View
  templateName: 'permissions_fields_picker'

  initialize: (options = {}) ->
    @parentView = options.parentView
    super

    @option_views = []
    @on 'ready', @initOptions

    @parentView.on 'change:picker_options', => @render(); @show()
    @hide()
    @render()

    $(document).on 'click', (e) =>
      unless (_.any $(e.target).parents(), (el) => el == @parentView.el)
        @hide()

  initInput: (el) =>
    @input = new PickerInputView parentView: @, el: el

  initOptions: =>
    for view in @option_views
      view.destroy()

    should_activate_first_option = true
    active_option_value = @option_views[@active_option]?.getValue()
    @active_option = null
    @option_views = []
    option_els = $('li.option', @el)
    for option, index in (@matches || [])
      el = option_els[index]
      view = new PickerOptionView parentView: @, el: el, index: index
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
       q.match(/^https?:\/\/[^.]+\..{2,}$/i) && !_.any(@parentView.options_view.options, (o) => o.value == q)
      @matches.unshift({
        entity: q
        value: q
      })
    if !@matches.length && !@current_query?.match(/^[\s\r\t\n]*$/) && "Everyone".score(@current_query) &&
       !_.any(@parentView.options_view.options, (o) => o.value == 'all')
      @matches.unshift({
        name: 'Everyone'
        value: 'all'
        group: true
      })
    @render()

  fetchResults: (query) =>
    return if @current_query == query
    @current_query = query
    return @displayMatches([]) if query.match(/^[\s\r\t\n]*$/)
    matched_entities = {}
    matches = []
    complete = (results, nextPage) =>
      return unless @current_query == query
      return unless results && nextPage
      for result in results
        result.score = ((result.name || "").score(query) + result.entity.score(query))
        result.value = result.entity
        if result.score
          matches.push(result)
      matches = _.filter matches, (m) => m.score && !@parentView.optionsInclude(m)
      matches = _.sortBy matches, (m) => m.score * -1
      @displayMatches(matches)

      if matches.length < 3 || _.first(matches).score < 0.6
        nextPage(complete)

    @fetchFollowings complete

  fetchProfile: (entity, callback) =>
    TentStatus.Models.Profile.fetchEntityProfile entity, (profile) =>
      callback(profile)

  fetchProfiles: (results, callback) =>
    _num_remaining = results.length
    complete = =>
      _num_remaining -= 1
      callback(results) if _num_remaining == 0

    for result, index in results
      do (result, index) =>
        @input.showLoading()
        @fetchProfile result.entity, (profile) =>
          @input.hideLoading()
          basic = profile?['https://tent.io/types/info/basic/v0.1.0']
          results[index].name = basic?.name
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
        new HTTP 'GET', "#{TentStatus.config.domain_tent_api_root}/followings", params, (res, xhr) =>
          return callback() unless xhr.status == 200
          @input.hideLoading()

          if id = _.last(res)?.id
            params.before_id = id

          results = _.map res, (follow) =>
            { entity: follow.entity, id: follow.id }

          @fetchProfiles results, (results) =>
            TentStatus.Cache.set cache_key, results, cache_options
            callback(results, nextPage)

    nextPage()

  context: =>
    options: @matches
    query: @current_query

  render: =>
    html = super
    @$el.html(html)
    @trigger 'ready'

  hide: =>
    $(@el.parentNode).hide()

  show: =>
    $(@el.parentNode).show()

class PickerOptionView
  constructor: (params = {}) ->
    @[k] = v for k,v of params

    @permissions_fields_view = @parentView.parentView

    @elements = {}

    unless @is_input
      $(@el).on 'click', (e) =>
        e.stopPropagation()
        @add()
      $(@el).on 'mouseover', (e) =>
        @parentView.option_views[@parentView.active_option]?.unsetActive()
        @setActive(false)

  getOption: =>
    @parentView.matches[@index]

  getValue: =>
    @getOption()?.value

  getText: =>
    @getOption().name || @getOption().entity.replace(/^https?:\/\/(?:www\.)?/, '')

  isGroup: =>
    !!@getOption().group

  destroy: =>
    $(@el).remove()

  scrollIntoView: =>
    offset = @el.offsetTop
    scrollY = @parentView.el.scrollTop

    if offset < scrollY
      @parentView.el.scrollTop = offset
    else if (offset + $(@el).height()) > (scrollY + $(@parentView.el).height())
      @parentView.el.scrollTop = offset - $(@parentView.el).height() + $(@el).outerHeight()

  setActive: (should_scroll = true) =>
    @active = true
    @parentView.active_option = @index
    $(@el).addClass('active')

    @scrollIntoView() if should_scroll

  unsetActive: =>
    @active = false
    if @parentView.active_option == @index
      @parentView.active_option = null
    $(@el).removeClass('active')

  add: =>
    @permissions_fields_view.addOption {
      text: @getText()
      value: @getValue()
      group: @isGroup()
    }
    @destroy()
    views = @parentView.option_views
    @parentView.option_views = views.slice(0, @index).concat(views.slice(@index+1, views.length))
    matches = @parentView.matches
    @parentView.matches = matches.slice(0, @index).concat(matches.slice(@index+1, matches.length))

    for view, index in @parentView.option_views
      view.index = index

class PickerInputView extends PickerOptionView
  constructor: ->
    @is_input = true
    super
    @elements.input = $('input[type=text]', @el).get(0)

    @elements.loading = $('.loading', @el).get(0)
    @loading_view = new TentStatus.Views.LoadingIndicator el: @elements.loading

    $(@elements.input).on 'keydown', (e) =>
      switch e.keyCode
        when 13 # enter/return
          e.preventDefault()
          @parentView.addActiveOption()
          false
        when 27 # escape
          e.preventDefault()
          @clear()
          @parentView.hide()
          false
        when 38 # up arrow
          e.preventDefault()
          @parentView.prevOption()
          false
        when 40 # down arrow
          e.preventDefault()
          @parentView.nextOption()
          false

    $(@elements.input).on 'keyup', (e) =>
      clearTimeout @_fetch_timeout
      @_fetch_timeout = setTimeout (=> @parentView.fetchResults(@elements.input.value)), 60

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

  showLoading: =>
    @_loading_requests ?= 0
    @_loading_requests += 1
    @loading_view.show() if @_loading_requests == 1

  hideLoading: =>
    @_loading_requests ?= 1
    @_loading_requests -= 1
    @loading_view.hide() if @_loading_requests == 0

