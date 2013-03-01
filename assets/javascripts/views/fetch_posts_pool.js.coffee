Marbles.Views.FetchPostsPool = class FetchPostsPoolView extends Marbles.View
  @template_name: 'fetch_posts_pool'
  @view_name: 'fetch_posts_pool'

  constructor: (options = {}) ->
    super

    @on 'ready', @bindLink

    @fetch_interval = new TentStatus.FetchInterval fetch_callback: @fetchPosts
    @parent_view.on 'init-view', (view_class_name, posts_feed_view) =>
      return unless view_class_name.match /PostsFeed$/
      @posts_feed_view_cid = posts_feed_view.cid
      posts_feed_view.posts_collection.once 'fetch:success', (posts_collection) =>
        @posts_collection = new TentStatus.Collections.Posts
        @posts_collection.pagination_params = {
          prev: posts_collection.pagination_params.prev
        }
        @fetch_interval.start()

    TentStatus.Models.Post.on 'create:success', (post, xhr) =>
      return unless @posts_collection
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
    posts_feed_view.prependRender(@posts_collection.models())
    posts_feed_view.posts_collection.prependModels(@posts_collection.model_ids)
    @posts_collection.empty()
    @render()

  context: =>
    posts_count: @posts_collection.model_ids.length

  bindLink: =>
    link_element = Marbles.DOM.querySelector('.fetch-posts-pool', @el)
    Marbles.DOM.on link_element, 'click', (e) =>
      e.preventDefault()
      @emptyPool()
