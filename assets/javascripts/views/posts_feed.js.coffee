TentStatus.Views.PostsFeed = class PostsFeedView extends TentStatus.View
  @template_name: 'posts_feed'
  @partial_names: ['_reply_form', '_post', '_post_inner', '_post_inner_actions']

  constructor: (options = {}) ->
    super

    @on 'ready', @initPostViews
    @on 'ready', @initAutoPaginate

    @posts_collection = new TentStatus.Collections.Posts
    @fetch()

  fetch: (params = {}, options = {}) =>
    @pagination_frozen = true

    TentStatus.trigger 'loading:start'
    @posts_collection.fetch params, _.extend(options,
      success: (posts) =>
        TentStatus.trigger 'loading:stop'
        @posts_collection.before_id = _.last(posts)?.id
        @posts_collection.before_id_entity = _.last(posts)?.entity

        unless posts.length
          @last_page = true

        if options.append
          @appendRender(posts)
        else
          @render()

      error: (res, xhr) =>
        TentStatus.trigger 'loading:stop'
    )

  nextPage: =>
    @fetch {
      before_id: @posts_collection.before_id
      before_id_entity: @posts_collection.before_id_entity
    }, {
      append: true
    }

  postContext: (post) =>
    TentStatus.Views.Post::context(post)

  context: (posts = @posts_collection.models()) =>
    posts: _.map(posts, (post) => @postContext(post))

  appendRender: (posts) =>
    html = ""
    for post in posts
      html += @constructor.partials['_post'].render(@postContext(post), @constructor.partials)

    console.log @el
    DOM.appendHTML(@el, html)
    @bindViews(keep_existing: true)
    @pagination_frozen = false

  render: =>
    @pagination_frozen = false
    super

  initPostViews: =>

  initAutoPaginate: =>
    TentStatus.on 'window:scroll', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    return if @pagination_frozen || @last_page
    last_post = DOM.querySelector('li.post:last-of-type', @el)
    return unless last_post
    last_post_offset_top = last_post.offsetTop || 0
    last_post_offset_top += last_post.offsetHeight || 0
    bottom_position = window.scrollY + DOM.windowHeight()

    if last_post_offset_top <= bottom_position
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @nextPage, 0 unless @last_page

