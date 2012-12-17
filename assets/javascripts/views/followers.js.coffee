TentStatus.Views.Followers = class FollowersView extends TentStatus.View
  @template_name: 'followers'
  @partial_names: ['_follower']
  @view_name: 'followers'

  constructor: (options = {}) ->
    @container = TentStatus.Views.container
    super

    @elements = {}

    @on 'ready', @init
    @on 'ready', @initAutoPaginate

    @entity = options.entity
    @initFollowersCollection(entity: options.entity)

  init: =>
    @elements.tbody = DOM.querySelector('tbody', @el)

  initFollowersCollection: (options = {}) =>
    unless options.client
      return HTTP.TentClient.fetch {entity: options.entity}, (client) =>
        @initFollowersCollection(_.extend(options, {client: client}))

    @followers_collection = new TentStatus.Collections.Followers
    @followers_collection.client = options.client

    TentStatus.Models.Follower.on 'delete:success', (follower) =>
      @followers_collection.remove(follower)
      for el in DOM.querySelectorAll("[data-cid=#{follower.cid}]", @el)
        DOM.removeNode(el)

    @fetch()

  fetch: (params = {}, options = {}) =>
    @pagination_frozen = true

    TentStatus.trigger 'loading:start'
    @followers_collection.fetch params, _.extend(options,
      success: (followers) =>
        TentStatus.trigger 'loading:stop'
        @followers_collection.before_id = _.last(followers)?.id

        unless followers.length
          @last_page = true

        if options.append
          @appendRender(followers)
        else
          @render()

      error: (res, xhr) =>
        TentStatus.trigger 'loading:stop'
    )

  nextPage: =>
    @fetch {
      before_id: @followers_collection.before_id
    }, {
      append: true
    }

  followerContext: (follower) =>
    TentStatus.Views.Follower::context(follower)

  context: (followers = @followers_collection.models()) =>
    _.extend super,
      followers: _.map(followers, (follower) => @followerContext(follower))
      entity_authenticated: TentStatus.config.authenticated && TentStatus.config.current_entity.assertEqual(@entity)

  appendRender: (followers) =>
    html = ""
    for follower in followers
      html += @constructor.partials['_follower'].render(@followerContext(follower), @constructor.partials)

    DOM.appendHTML(@elements.tbody, html)
    @bindViews()
    @pagination_frozen = false

  prependRender: (followers) =>
    html = ""
    for follower in followers
      html += @constructor.partials['_follower'].render(@followerContext(follower), @constructor.partials)

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
    last_follower = DOM.querySelector('tr.follower:last-of-type', @el)
    return unless last_follower
    last_follower_offset_top = last_follower.offsetTop || 0
    last_follower_offset_top += last_follower.offsetHeight || 0
    bottom_position = window.scrollY + DOM.windowHeight()

    if last_follower_offset_top <= bottom_position
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @nextPage, 0 unless @last_page

