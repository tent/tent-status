class StatusPro.Views.Posts extends StatusPro.View
  templateName: 'posts'
  partialNames: ['_post', '_new_post_form', '_reply_form']

  dependentRenderAttributes: ['posts', 'groups', 'followers', 'followings', 'profile']

  initialize: ->
    @container = StatusPro.Views.container
    super

    @on 'ready', @initPostViews

  sortedPosts: => @posts.sortBy (post) -> -post.get('published_at')

  uniqueFollowings: =>
    @followings.filter (following) =>
      !@followers.find (follower) =>
        follower.get('entity') == following.get('entity')

  licenseName: (url) =>
    for l in @licenses || []
      return l.name if l.url == url
    url

  context: =>
    @licenses = [{ url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", name: "Creative Commons by-nc-sa 3.0" }]

    groups: @groups.toJSON()
    follows: _.map(@followers.toArray().concat(@uniqueFollowings()), (follow) -> _.extend follow.toJSON(), {
      name: follow.name()
    })
    licenses: @licenses
    posts: _.map(@sortedPosts(), (post) => _.extend post.toJSON(), {
      shouldShowReply: true
      name: post.name()
      avatar: post.avatar()
      licenses: _.map post.get('licenses'), (url) => { name: @licenseName(url), url: url }
      escaped:
        entity: encodeURIComponent(post.get('entity'))
      formatted:
        published_at: StatusPro.Helpers.formatTime post.get('published_at')
        full_published_at: StatusPro.Helpers.rawTime post.get('published_at')
    })

  initPostViews: =>
    _.each ($ 'li.post'), (el) =>
      new StatusPro.Views.Post el: el, parentView: @

