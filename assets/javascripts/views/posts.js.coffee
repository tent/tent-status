class StatusPro.Views.Posts extends StatusPro.View
  templateName: 'posts'
  partialNames: ['_post', '_new_post_form']

  dependentRenderAttributes: ['posts', 'groups', 'followers', 'followings', 'profile']

  initialize: ->
    @container = StatusPro.Views.container
    super

  sortedPosts: => @posts.sortBy (post) -> -post.get('published_at')

  uniqueFollowings: =>
    @followings.filter (following) =>
      !@followers.find (follower) =>
        follower.get('entity') == following.get('entity')

  context: =>
    groups: @groups.toJSON()
    follows: _.map(@followers.toArray().concat(@uniqueFollowings()), (follow) -> _.extend follow.toJSON(), {
      name: follow.name()
    })
    posts: _.map(@sortedPosts(), (post) -> _.extend post.toJSON(), {
      name: post.name()
      avatar: post.avatar()
      formatted:
        published_at: StatusPro.Helpers.formatTime post.get('published_at')
        full_published_at: StatusPro.Helpers.rawTime post.get('published_at')
    })
