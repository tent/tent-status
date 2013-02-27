Marbles.Views.PostsFeed = class PostsFeedView extends TentStatus.View
  @template_name: 'posts_feed'
  @partial_names: ['_post_reply_form', '_post', '_post_inner', '_post_inner_actions']
  @view_name: 'posts_feed'

  constructor: (options = {}) ->
    super
    @init()

  init: =>
    @on 'ready', @initPostViews
    @on 'ready', @initAutoPaginate

    @posts_collection = new TentStatus.Collections.Posts
    @fetch()

    TentStatus.Models.Post.on 'create:success', (post, xhr) =>
      @posts_collection.unshift(post)
      @prependRender([post])

  fetch: (params = {}, options = {}) =>
    @pagination_frozen = true

    TentStatus.trigger 'loading:start'
    @posts_collection.fetch params, _.extend(options,
      success: @fetchSuccess
      error: @fetchError
    )

  fetchSuccess: (posts, xhr, params, options) =>
    TentStatus.trigger 'loading:stop'

    unless posts.length
      @last_page = true

    if options.append
      @appendRender(posts)
    else
      @render()

  fetchError: (res, xhr) =>
    TentStatus.trigger 'loading:stop'

  nextPage: =>
    @pagination_frozen = true
    @posts_collection.fetchNext(append: true, success: @fetchSuccess, error: @fetchError)

  postContext: (post) =>
    Marbles.Views.Post::context(post)

  context: (posts = @posts_collection.models()) =>
    posts: _.map(posts, (post) => @postContext(post))

  appendRender: (posts) =>
    html = ""
    for post in posts
      html += @constructor.partials['_post'].render(@postContext(post), @constructor.partials)

    Marbles.DOM.appendHTML(@el, html)
    @bindViews()
    @pagination_frozen = false

  prependRender: (posts) =>
    html = ""
    for post in posts
      html += @constructor.partials['_post'].render(@postContext(post), @constructor.partials)

    Marbles.DOM.prependHTML(@el, html)
    @bindViews()

  render: =>
    @pagination_frozen = false
    super

  initPostViews: =>

  initAutoPaginate: =>
    TentStatus.on 'window:scroll', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    return if @pagination_frozen || @last_page
    last_post = Marbles.DOM.querySelector('li.post:last-of-type', @el)
    return unless last_post
    last_post_offset_top = last_post.offsetTop || 0
    last_post_offset_top += last_post.offsetHeight || 0
    bottom_position = window.scrollY + Marbles.DOM.windowHeight()

    if last_post_offset_top <= bottom_position
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @nextPage, 0 unless @last_page

