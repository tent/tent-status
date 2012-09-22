class TentStatus.Views.Post extends TentStatus.View
  templateName: '_post'

  initialize: (options = {}) ->
    @parentView = options.parentView
    @post = options.post

    @post?.on 'change:profile', => @render()

    super

  repostContext: (post, repost) =>
    return false unless post.isRepost()

    repost ?= _.find @parentView.posts.toArray() || [], ((p) => p.get('id') == post.get('content')['id'])
    return false unless repost
    _.extend( @context(repost), {
      parent: { name: post.name(), id: post.get('id') }
    })

  postProfileJSON: (post) =>
    hasName: post.get('profile')?.hasName() || false
    name: post.get('profile')?.name() || ''
    avatar: post.get('profile')?.avatar() || ''

  context: (post = @post, repostContext) =>
    _.extend super, post.toJSON(), @postProfileJSON(post), {
      is_repost: post.isRepost()
      repost: repostContext || @repostContext(post)
      in_reply_to: post.get('in_reply_to_post')
      url: TentStatus.Helpers.postUrl(post)
      profileUrl: TentStatus.Helpers.entityProfileUrl(post.get 'entity')
      licenses: _.map post.get('licenses') || [], (url) => { name: TentStatus.Helpers.formatUrl(url), url: url }
      escaped:
        entity: encodeURIComponent( post.get 'entity' )
      formatted:
        entity: TentStatus.Helpers.formatUrl post.get('entity')
        published_at: TentStatus.Helpers.formatTime post.get('published_at')
        full_published_at: TentStatus.Helpers.rawTime post.get('published_at')
      currentUserOwnsPost: TentStatus.config.current_entity.assertEqual( new HTTP.URI post.get('entity') )
    }

  render: (context = @context()) =>
    html = @template.render(context, @parentView.partials)
    el = ($ html)
    @$el.replaceWith(el)
    @setElement el
    @trigger 'ready'

