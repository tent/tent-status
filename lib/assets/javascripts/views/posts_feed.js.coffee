Marbles.Views.PostsFeed = class PostsFeedView extends Marbles.View
  @template_name: 'posts_feed'
  @partial_names: ['_post_reply_form', '_post', '_post_inner', '_post_inner_actions']
  @view_name: 'posts_feed'
  @last_post_selector: "ul[data-view=PostsFeed]>li.post:last-of-type"

  showLoading: =>
    TentStatus.trigger 'loading:start'

  hideLoading: =>
    TentStatus.trigger 'loading:stop'

  initialize: (options = {}) =>
    @entity = options.entity || TentStatus.config.meta.content.entity
    @types = options.types || TentStatus.config.feed_types
    @feed_headers = options.headers || {}

    default_queries = [
      { profiles: 'entity,refs', max_refs: 1, entities: options.entity || false },
      { types: [TentStatus.config.POST_TYPES.STATUS_REPLY], mentions: 'subscribing', profiles: 'entity,refs', entities: options.entity || false },
      { types: [TentStatus.config.POST_TYPES.STATUS_REPLY], entities: @entity, profiles: 'entity' }
    ]
    @feed_queries = _.map options.feed_queries || default_queries, (q) => q.types ?= @types; q
    @collection_contexts = _.map @feed_queries, (feed_params) =>
      TentStatus.Collections.Posts.generateContext('feed', { params: feed_params, headers: @feed_headers })

    # fire focus event for first post view in feed (caught by author info view)
    # TODO: find a better way to do this!
    @once 'ready', =>
      first_post_view = @childViews('Post')?[0]
      if first_post_view
        first_post_view.constructor.trigger('focus', first_post_view)

    @on 'ready', @initAutoPaginate

    @fetch()

    TentStatus.Models.StatusPost.on 'create:success', (post, xhr) =>
      return unless @shouldAddPostToFeed(post)
      collection = @postsCollection()
      return unless @shouldAddPostTypeToFeed(post.get('type'), collection.postTypes())
      collection.unshift(post)
      @prependRender([post])

  shouldAddPostTypeToFeed: (prospect_type, types = @postsCollection().postTypes()) =>
    prospect_type = new TentClient.PostType prospect_type
    _.any types, (type) =>
      type = new TentClient.PostType type
      type.assertMatch(prospect_type)

  shouldAddPostToFeed: (post) =>
    return false if post.get('type') is TentStatus.config.POST_TYPES.STATUS_REPLY && post.get('entity') != @entity
    true

  initFeedQueries: =>

  postsCollection: =>
    @unified_posts_collection || @initPostsCollection()

  initPostsCollection: =>
    collections = []
    for feed_params, index in @feed_queries
      _collection_context = @collection_contexts[index]
      _collection = TentStatus.Collections.Posts.find(entity: @entity, context: _collection_context)
      _collection ?= new TentStatus.Collections.Posts(entity: @entity, context: _collection_context)
      _collection.options.params = feed_params
      _collection.options.headers = @feed_headers
      _collection.options.tent_client = @tent_client if @tent_client

      collections.push(_collection)

    @unified_posts_collection = new TentStatus.UnifiedCollection(collections)

  fetch: (params = {}, options = {}) =>
    @pagination_frozen = true

    @showLoading()
    @postsCollection().fetch params, _.extend({}, options,
      success: @fetchSuccess
      failure: @fetchError
      complete: @hideLoading
    )

  fetchNext: =>
    @pagination_frozen = true

    @showLoading()
    @last_page = true if @postsCollection().fetchNext(
      append: true
      success: @fetchSuccess
      failure: @fetchError
      complete: @hideLoading
    ) is false
    @hideLoading() if @last_page

  fetchSuccess: (posts, res, xhr, params, options) =>
    if options.append
      @appendRender(posts)
    else
      @render(@context(posts))

    @pagination_frozen = false

    # handle screen being very tall or limit very short
    @windowScrolled(true) if @shouldFetchNextPage()

  fetchError: (res, xhr) =>
    console?.warn?("#{@constructor.name}.prototype.fetchError", res, xhr)

  postContext: (post) =>
    Marbles.Views.Post::context(post)

  renderPostHTML: (post) =>
    @constructor.partials['_post'].render(@postContext(post), @constructor.partials)

  context: (posts = @postsCollection().models()) =>
    posts: _.map(posts, ((post) => @postContext(post)))

  appendRender: (posts) =>
    fragment = document.createDocumentFragment()
    for post in posts
      Marbles.DOM.appendHTML(fragment, @renderPostHTML(post))

    @bindViews(fragment)
    @el.appendChild(fragment)

  prependRender: (posts) =>
    fragment = document.createDocumentFragment()
    for post in posts
      Marbles.DOM.appendHTML(fragment, @renderPostHTML(post))

    @bindViews(fragment)
    Marbles.DOM.prependChild(@el, fragment)

  initAutoPaginate: =>
    TentStatus.on 'window:scroll',  => @windowScrolled()
    setTimeout @windowScrolled, 100

  shouldFetchNextPage: =>
    return false if @pagination_frozen || @last_page
    last_post = Marbles.DOM.querySelector(@constructor.last_post_selector, @el)
    return false unless last_post
    last_post_offset_top = last_post.offsetTop || 0
    last_post_offset_top += last_post.offsetHeight || 0
    bottom_position = window.scrollY + Marbles.DOM.windowHeight()

    last_post_offset_top <= bottom_position

  windowScrolled: (should_fetch_next_page) =>
    clearTimeout @_window_scrolled_timeout
    @_window_scrolled_timeout = setTimeout =>
      should_fetch_next_page ?= @shouldFetchNextPage()
      return unless should_fetch_next_page
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @fetchNext, 0 unless @last_page
    , 40

