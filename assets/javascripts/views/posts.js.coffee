class TentStatus.Views.Posts extends TentStatus.View
  templateName: 'posts'
  partialNames: ['_new_post_form']

  initialize: ->
    @container = TentStatus.Views.container
    super

  context: =>

    #   @on 'ready', @initPostViews
    #   @on 'ready', @initFetchPool
    #   @on 'ready', @initAutoPaginate
    #
    # sortedPosts: => @posts.sortBy (post) -> -post.get('published_at')
    #
    # uniqueFollowings: =>
    #   @followings?.filter (following) =>
    #     !@followers.find (follower) =>
    #       follower.get('entity') == following.get('entity')
    #
    # follows: =>
    #   (@followers?.toArray() || []).concat(@uniqueFollowings() || [])
    #
    # context: =>
    #   @licenses = [{ url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", name: "Creative Commons by-nc-sa 3.0" }]
    #
    #   follows: _.map(@follows(), (follow) -> _.extend follow.toJSON(), {
    #     name: follow.name()
    #   })
    #   licenses: @licenses
    #   posts: (_.map @posts.toArray(), (post) =>
    #     view = new TentStatus.Views.Post parentView: @
    #     view.context(post)
    #   )
    #
    # initPostViews: =>
    #   _.each ($ 'li.post'), (el) =>
    #     new TentStatus.Views.Post el: el, parentView: @
    #
    # initFetchPool: =>
    #   el = ($ '.fetch-pool', @container.$el).hide()
    #   @fetchPoolView = new TentStatus.Views.FetchPostsPool el: el, parentView: @
    #
    # initAutoPaginate: =>
    #   ($ window).off 'scroll.posts'
    #   ($ window).on 'scroll.posts', (e)=>
    #     height = $(document).height() - $(window).height()
    #     delta = height - window.scrollY
    #     if delta < 300
    #       @posts?.nextPage() unless @posts.onLastPage
    #
    # emptyPool: =>
    #   @fetchPoolView.emptyPool()
    #
