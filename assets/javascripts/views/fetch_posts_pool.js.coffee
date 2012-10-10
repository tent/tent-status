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

  updateUnreadTitle: =>
    title = document.title
    unread_text = if @num_new_posts then "(#{@num_new_posts}) " else ""
    title = title.replace(/^(\(\d+\)\s*)*/, unread_text)
    TentStatus.setPageTitle title, {includes_base_title:true}

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

    @updateUnreadTitle()

    @show() if @num_new_posts > 0

  show: => @$el.show()
  hide: => @$el.hide()

  emptyPool: =>
    new_posts = @pool.sortBy (i) -> i.get('published_at')
    @pool.collection.reset()

    html = []
    for post in new_posts
      @posts.unshift(post)
      html.unshift TentStatus.Views.Post::renderHTML(TentStatus.Views.Post::context(post), @postsFeedView.partials)
    html = html.join('')

    $top_post = $('.post:first', @$elements.posts_list)
    @$elements.posts_list.prepend(html)

    _.each $top_post.prevAll('.post'), (el, index) =>
      view = new TentStatus.Views.Post el: el, post: new_posts[index], parentView: @postsFeedView
      view.trigger 'ready'

    @pool.since_id = @postsFeedView.posts.first()?.get('id')
    @num_new_posts = 0
    @$elements.num_new_posts.text @num_new_posts
    @hide()
    @updateUnreadTitle()

