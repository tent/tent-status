class StatusApp.Views.Posts extends StatusApp.View
  templateName: 'posts'
  partialNames: ['_post', '_new_post_form', '_reply_form']

  dependentRenderAttributes: ['posts', 'followers', 'followings', 'profile']

  initialize: ->
    @container = StatusApp.Views.container
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

  replyToPost: (post) =>
    return unless post.get('mentions')?.length
    for mention in post.get('mentions')
      if mention.entity and mention.post
        mention.url = "#{StatusApp.url_root}posts/#{encodeURIComponent(mention.entity)}/#{mention.post}"
        return mention
    null

  context: =>
    @licenses = [{ url: "http://creativecommons.org/licenses/by-nc-sa/3.0/", name: "Creative Commons by-nc-sa 3.0" }]

    follows: _.map(@followers.toArray().concat(@uniqueFollowings()), (follow) -> _.extend follow.toJSON(), {
      name: follow.name()
    })
    licenses: @licenses
    posts: _.map(@sortedPosts(), (post) => _.extend post.toJSON(), {
      shouldShowReply: true
      inReplyTo: @replyToPost(post)
      url: "#{StatusApp.url_root}/#{encodeURIComponent(post.get('entity'))}/#{post.get('id')}"
      name: post.name()
      avatar: post.avatar()
      licenses: _.map post.get('licenses'), (url) => { name: @licenseName(url), url: url }
      escaped:
        entity: encodeURIComponent(post.get('entity'))
      formatted:
        published_at: StatusApp.Helpers.formatTime post.get('published_at')
        full_published_at: StatusApp.Helpers.rawTime post.get('published_at')
    })

  initPostViews: =>
    _.each ($ 'li.post'), (el) =>
      new StatusApp.Views.Post el: el, parentView: @

