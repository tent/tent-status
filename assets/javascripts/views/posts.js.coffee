class StatusApp.Views.Posts extends StatusApp.View
  templateName: 'posts'
  partialNames: ['_post', '_new_post_form', '_reply_form', '_post_inner']

  dependentRenderAttributes: ['posts', 'followers', 'followings', 'profile']

  initialize: ->
    @container = StatusApp.Views.container
    super

    @on 'ready', @initPostViews

  sortedPosts: => @posts.sortBy (post) -> -post.get('published_at')

  uniqueFollowings: =>
    @followings?.filter (following) =>
      !@followers.find (follower) =>
        follower.get('entity') == following.get('entity')

  follows: =>
    (@followers?.toArray() || []).concat(@uniqueFollowings() || [])

  context: =>
    @licenses = [{ url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", name: "Creative Commons by-nc-sa 3.0" }]

    follows: _.map(@follows(), (follow) -> _.extend follow.toJSON(), {
      name: follow.name()
    })
    licenses: @licenses
    posts: (_.map @posts.toArray(), (post) =>
      view = new StatusApp.Views.Post parentView: @
      view.context(post)
    )

  initPostViews: =>
    _.each ($ 'li.post'), (el) =>
      new StatusApp.Views.Post el: el, parentView: @

