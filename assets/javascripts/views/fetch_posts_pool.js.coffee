class StatusApp.Views.FetchPostsPool extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @$numNewPosts = ($ '.num_new_posts', @$el)
    @numNewPosts = 0

    @$postsList = ($ 'ul.posts', @parentView.container.$el)

    @sinceId = @parentView.posts.first()?.get('id')
    @pool = new StatusApp.FetchPool( new StatusApp.Collections.Posts, { sinceId: @sinceId })
    @pool.on 'fetch:success', @update

    @fetchDelay = 3000
    @fetchDelayOffset = 0

    @setFetchInterval()

    @$el.on 'click', (e)=>
      e.preventDefault()
      @emptyPool()
      false
    
  setFetchInterval: (interval=@fetchDelay+@fetchDelayOffset) =>
    clearInterval @_fetchInterval
    @_fetchInterval = setInterval @pool.fetch, interval

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
      StatusApp.Collections.posts.unshift(post)
      @createPostView(post)
    @pool.sinceId = @parentView.posts.first()?.get('id') || @pool.sinceId
    @numNewPosts = 0
    @$numNewPosts.text @numNewPosts
    @hide()

  createPostView: (post) =>
    el = ($ '<li>').prependTo(@$postsList)
    view = new StatusApp.Views.Post el: el, parentView: @parentView
    context = view.context(post)
    view.render(context)
