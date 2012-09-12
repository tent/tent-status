class StatusPro.Views.Posts extends StatusPro.View
  templateName: 'posts'
  partialNames: ['_post', '_new_post_form']

  dependentRenderAttributes: ['posts', 'groups', 'followers', 'profile']

  initialize: ->
    @container = StatusPro.Views.container
    super

  sortedPosts: => @posts.sortBy (post) -> -post.get('published_at')

  context: =>
    groups: @groups.toJSON()
    followers: _.map(@followers.toArray(), (follower) -> _.extend follower.toJSON(), {
      name: follower.name()
    })
    posts: _.map(@sortedPosts(), (post) -> _.extend post.toJSON(), {
      name: post.name()
      avatar: post.avatar()
      formatted:
        published_at: StatusPro.Helpers.formatTime post.get('published_at')
        full_published_at: StatusPro.Helpers.rawTime post.get('published_at')
    })
