Marbles.Views.FetchPostsPool = class FetchPostsPoolView extends Marbles.View
  @template_name: 'fetch_posts_pool'
  @view_name: 'fetch_posts_pool'

  constructor: (options = {}) ->
    super

    @on 'ready', @bindLink

    @parentView().on('init-view', @parentViewInit)

  parentViewInit: (view_class_name, view) =>
    return unless view_class_name.match /PostsFeed$/

    @parentView().off('init-view', @parentViewInit)

    @posts_feed_view_cid = view.cid

    posts_feed_collection = view.postsCollection() # UnifiedCollection
    @pool = new TentStatus.UnifiedCollectionPool posts_feed_collection

    @pool.on 'pool:expand', @poolExpanded
    @pool.on 'pool:overflow', @poolExpanded

  poolExpanded: (size) =>
    @size = size
    @render()

  emptyPool: =>
    posts_feed_view = Marbles.View.instances.all[@posts_feed_view_cid]
    return unless posts_feed_view

    collection = @pool.shadowCollection()

    posts_feed_view.prependRender(collection.models())
    posts_feed_view.postsCollection().prependIds?(collection.model_ids...)

    @pool.reset()
    @size = 0

    @render()

  context: =>
    if !@size
      posts_count: null
    else if @size <= @pool.MAX_OVERFLOW_SIZE
      posts_count: @size
    else
      posts_count: "#{@pool.MAX_OVERFLOW_SIZE}+"

  bindLink: =>
    link_element = Marbles.DOM.querySelector('.fetch-posts-pool', @el)
    Marbles.DOM.on link_element, 'click', (e) =>
      e.preventDefault()
      @emptyPool()

  render: (context = @context()) =>
    super(context)

    if context.posts_count
      TentStatus.setPageTitle prefix: "(#{context.posts_count})"
    else
      TentStatus.setPageTitle prefix: null

