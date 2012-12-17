TentStatus.Views.Followings = class FollowingsView extends TentStatus.View
  @template_name: 'followings'
  @partial_names: ['_following']
  @view_name: 'followings'

  constructor: (options = {}) ->
    @container = TentStatus.Views.container
    super

    @elements = {}

    @on 'ready', @init
    @on 'ready', @initAutoPaginate

    @entity = options.entity
    @initFollowingsCollection(entity: options.entity)

  init: =>
    @elements.tbody = DOM.querySelector('tbody', @el)

  initFollowingsCollection: (options = {}) =>
    unless options.client
      return HTTP.TentClient.fetch {entity: options.entity}, (client) =>
        @initFollowingsCollection(_.extend(options, {client: client}))

    @followings_collection = new TentStatus.Collections.Followings
    @followings_collection.client = options.client


    TentStatus.Models.Following.on 'create:success', (following) =>
      return if @followings_collection.includes(following)
      @followings_collection.unshift(following)
      @prependRender([following])

    TentStatus.Models.Following.on 'delete:success', (following) =>
      @followings_collection.remove(following)
      for el in DOM.querySelectorAll("[data-cid=#{following.cid}]", @el)
        DOM.removeNode(el)

    @fetch()

  fetch: (params = {}, options = {}) =>
    @pagination_frozen = true

    TentStatus.trigger 'loading:start'
    @followings_collection.fetch params, _.extend(options,
      success: (followings) =>
        TentStatus.trigger 'loading:stop'
        @followings_collection.before_id = _.last(followings)?.id

        unless followings.length
          @last_page = true

        if options.append
          @appendRender(followings)
        else
          @render()

      error: (res, xhr) =>
        TentStatus.trigger 'loading:stop'
    )

  nextPage: =>
    @fetch {
      before_id: @followings_collection.before_id
    }, {
      append: true
    }

  followingContext: (following) =>
    TentStatus.Views.Following::context(following)

  context: (followings = @followings_collection.models()) =>
    _.extend super,
      followings: _.map(followings, (following) => @followingContext(following))
      entity_authenticated: TentStatus.config.authenticated && TentStatus.config.current_entity.assertEqual(@entity)

  appendRender: (followings) =>
    html = ""
    for following in followings
      html += @constructor.partials['_following'].render(@followingContext(following), @constructor.partials)

    DOM.appendHTML(@elements.tbody, html)
    @bindViews()
    @pagination_frozen = false

  prependRender: (followings) =>
    html = ""
    for following in followings
      html += @constructor.partials['_following'].render(@followingContext(following), @constructor.partials)

    if new_following_form = DOM.querySelector('tr[data-view=NewFollowingForm]', @el)
      DOM.insertHTMLAfter(html, new_following_form)
    else
      DOM.prependHTML(@elements.tbody, html)
    @bindViews()
    @pagination_frozen = false

  render: =>
    @pagination_frozen = false
    super

  initAutoPaginate: =>
    TentStatus.on 'window:scroll', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    return if @pagination_frozen || @last_page
    last_following = DOM.querySelector('tr.following:last-of-type', @el)
    return unless last_following
    last_following_offset_top = last_following.offsetTop || 0
    last_following_offset_top += last_following.offsetHeight || 0
    bottom_position = window.scrollY + DOM.windowHeight()

    if last_following_offset_top <= bottom_position
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @nextPage, 0 unless @last_page

