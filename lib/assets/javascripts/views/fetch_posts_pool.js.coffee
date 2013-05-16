Marbles.Views.FetchPostsPool = class FetchPostsPoolView extends Marbles.View
  @template_name: 'fetch_posts_pool'
  @view_name: 'fetch_posts_pool'

  constructor: (options = {}) ->
    super
    return console.warn("TODO: Implement FetchPostsPool")

    @on 'ready', @bindLink

    @fetch_interval = new TentStatus.FetchInterval fetch_callback: @fetchPosts
    @parentView().on 'init-view', (view_class_name, posts_feed_view) =>
      return unless view_class_name.match /PostsFeed$/
      @posts_feed_view_cid = posts_feed_view.cid
      posts_feed_view.posts_collection.once 'fetch:success', (posts_collection) =>
        @posts_collection = new TentStatus.Collections.Posts
        @posts_collection.client = posts_collection.client
        @posts_collection.params = posts_collection.params
        @posts_collection.pagination_params = {
          prev: posts_collection.pagination_params?.prev || {}
        }
        @fetch_interval.start()

    TentStatus.Models.Post.on 'create:success', (post, xhr) =>
      return unless @posts_collection

      # TODO: find another way of doing this
      @posts_collection.ignoreCid(post.cid)

  fetchPosts: =>
    @posts_collection.fetchPrev success: @fetchSuccess, error: @fetchError, prepend: true

  fetchSuccess: (posts) =>
    if posts.length
      @fetch_interval.reset()
      @render()
    else
      @fetch_interval.increaseDelay()

  fetchError: =>
    @fetch_interval.increaseDelay()

  emptyPool: =>
    posts_feed_view = Marbles.View.instances.all[@posts_feed_view_cid]
    return unless posts_feed_view

    last_post_cid = _.last(@posts_collection.model_ids)

    posts_feed_view.prependRender(@posts_collection.models())
    posts_feed_view.posts_collection.prependModels(@posts_collection.model_ids)
    @posts_collection.empty()

    # Update Mentions Profile Cursor / Unread Badge
    if posts_feed_view.constructor.view_name == 'mentions_posts_feed'
      posts_feed_view.updateProfileCursor?(@posts_collection)

    @render()

  context: =>
    posts_count: @posts_collection.model_ids.length

  bindLink: =>
    link_element = Marbles.DOM.querySelector('.fetch-posts-pool', @el)
    Marbles.DOM.on link_element, 'click', (e) =>
      e.preventDefault()
      @emptyPool()

  render: =>
    context = @context()
    super(context)

    if context.posts_count
      TentStatus.setPageTitle prefix: "(#{context.posts_count})"
    else
      TentStatus.setPageTitle prefix: null

