class TentStatus.Views.FetchPostsPool extends Backbone.View
  initialize: (@options = {}) ->
    @parentView = @options.parentView
    posts_feed_class = @$el.attr('data-posts-feed') or 'PostsFeed'
    unless @postsFeedView = @parentView.child_views[posts_feed_class]?[0]
      return @parentView.once "init:#{posts_feed_class}", => @initialize(@options)

    @$elements = {
      num_new_posts: ($ '.num_new_posts', @$el)
      posts_list: @postsFeedView.$el
    }

    @num_new_posts = 0

    @postsFeedView.on 'change:posts', @initFetchPool
    @initFetchPool() if @postsFeedView.posts?.length

  initFetchPool: =>
    @posts = @postsFeedView.posts

    params = _.extend {
      sinceId: @posts.first()?.get('id')
      since_id_entity: @posts.first()?.get('entity')
      master_collection: @posts
      url: @posts.url
    }, (@options.params || {})

    params.params = _.extend {
      post_types: TentStatus.config.post_types
    }, (@postsFeedView.options?.posts_params || {})

    @pool = new TentStatus.FetchPool(new TentStatus.Collections.Posts, params)
    @pool.on 'fetch:success', @update

    @fetch_delay = TentStatus.config.FETCH_INTERVAL
    @fetch_delay_offset = 0

    @setFetchInterval()

    @$el.off('click.empty-pool').on 'click.empty-pool', (e)=>
      e.preventDefault()
      @emptyPool()
      false
    
  setFetchInterval: (interval=@fetch_delay+@fetch_delay_offset) =>
    clearInterval TentStatus._fetchPostsPoolInterval
    TentStatus._fetchPostsPoolInterval = setInterval @pool.fetch, interval

  update: =>
    last_since_id = @since_id
    @since_id = @pool.since_id

    if last_since_id == @since_id
      @fetch_delay_offset = Math.min(@fetch_delay_offset + @fetch_delay, TentStatus.config.MAX_FETCH_LATENCY - @fetch_delay)
      @setFetchInterval()
    else
      @fetch_delay_offset = 0
      @setFetchInterval()

    @num_new_posts = @pool.collection.length
    @$elements.num_new_posts.text @num_new_posts

    @show() if @num_new_posts > 0

  show: => @$el.show()
  hide: => @$el.hide()

  emptyPool: =>
    for i in [0...@num_new_posts]
      post = @pool.collection.shift()
      @posts.unshift(post)
      TentStatus.Views.Post.insertNewPost(post, @$elements.posts_list, @postsFeedView)

    @pool.since_id = @postsFeedView.posts.first()?.get('id')
    @num_new_posts = 0
    @$elements.num_new_posts.text @num_new_posts
    @hide()

