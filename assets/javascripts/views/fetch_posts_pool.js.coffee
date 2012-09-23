class TentStatus.Views.FetchPostsPool extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView
    unless @postsFeedView = @parentView.child_views.PostsFeed?[0]
      return @parentView.once 'init:PostsFeed', => @initialize(options)

    @$elements = {
      num_new_posts: ($ '.num_new_posts', @$el)
      posts_list: @postsFeedView.$el
    }

    @num_new_posts = 0

    @postsFeedView.on 'change:posts', @initFetchPool
    @initFetchPool() if @postsFeedView.posts?.length

  initFetchPool: =>
    @posts = @postsFeedView.posts

    @since_id = @posts.first()?.get('id')
    @since_id_entity = @posts.first()?.get('entity')
    @pool = new TentStatus.FetchPool( new TentStatus.Collections.Posts, { since_id_entity: @since_id_entity, sinceId: @since_id, master_collection: @posts })
    @pool.on 'fetch:success', @update

    @fetch_delay = 3000
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
      @fetch_delay_offset = Math.min(@fetch_delay_offset + @fetch_delay, 60000 - @fetch_delay) # max delay: 1 min
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

