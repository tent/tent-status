class TentStatus.Views.FetchPostsPool extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @$numNewPosts = ($ '.num_new_posts', @$el)
    @numNewPosts = 0

    @$postsList = ($ 'ul.posts', @parentView.container.$el)

    @sinceId = @parentView.posts.first()?.get('id')
    @pool = new TentStatus.FetchPool( new TentStatus.Collections.Posts, { sinceId: @sinceId })
    @pool.on 'fetch:success', @update

    @fetchDelay = 3000
    @fetchDelayOffset = 0

    @setFetchInterval()

    @$el.on 'click', (e)=>
      e.preventDefault()
      @emptyPool()
      false
    
  setFetchInterval: (interval=@fetchDelay+@fetchDelayOffset) =>
    clearInterval TentStatus._fetchPostsPoolInterval
    TentStatus._fetchPostsPoolInterval = setInterval @pool.fetch, interval

  update: =>
    lastSinceId = @sinceId
    @sinceId = @pool.sinceId
    if lastSinceId == @sinceId
      @fetchDelayOffset = Math.min(@fetchDelayOffset + @fetchDelay, 57000) # max delay: 1 min
      @setFetchInterval()
    else
      @fetchDelayOffset = 0
      @setFetchInterval()

    @numNewPosts = @pool.collection.length
    @$numNewPosts.text @numNewPosts
    @show() if @numNewPosts > 0

  show: => @$el.show()
  hide: => @$el.hide()

  emptyPool: =>
    for i in [0...@numNewPosts]
      post = @pool.collection.shift()
      @parentView.posts.unshift(post)
      TentStatus.Collections.posts.unshift(post)
      # @createPostView(post)
    @parentView.render()
    @pool.sinceId = @parentView.posts.first()?.get('id') || @pool.sinceId
    @numNewPosts = 0
    @$numNewPosts.text @numNewPosts
    @hide()

  createPostView: (post) =>
    el = ($ '<li>').prependTo(@$postsList)
    view = new TentStatus.Views.Post el: el, parentView: @parentView
    view.post = post
    context = view.context(post)
    view.render(context)
