TentStatus.Views.Post = class PostView extends TentStatus.View
  @template_name: '_post'
  @view_name: 'post'

  constructor: ->
    super

    @post_cid = DOM.attr(@el, 'data-post_cid')

  repostContext: (post, repost) =>
    return false unless post.isRepost()

    repost ?= post.get('repost')
    return false unless repost
    return false if post.get('id') == repost.get('id')
    _.extend( @context(repost), {
      parent: { name: post.name(), id: post.get('id'), app: post.get('app') }
      has_parent: true
    })

  inReplyToJSON: (mention) =>
    return unless mention && mention.entity && mention.post
    {
      name: TentStatus.Helpers.formatUrlWithPath(mention.entity),
      url: TentStatus.Helpers.entityPostUrl(mention.entity, mention.post)
    }

  getPermissibleEntities: (post, should_trim=true) =>
    _entities = []
    for entity, can_see of (post.get('permissions').entities || {})
      continue unless can_see
      entity = TentStatus.Helpers.minimalEntity(entity) if should_trim
      _entities.push(entity)
    _entities

  context: (post = @post, repostContext) =>
    permissible_entities = @getPermissibleEntities(post)
    context = _.extend super, post.toJSON(), {
      cid: post.cid
      is_repost: post.isRepost()
      repost: repostContext || @repostContext(post)
      in_reply_to: @inReplyToJSON(post.postMentions()[0])
      url: TentStatus.Helpers.postUrl(post)
      profileUrl: TentStatus.Helpers.entityProfileUrl(post.get 'entity')
      licenses: _.map post.get('licenses') || [], (url) => { name: TentStatus.Helpers.formatUrl(url), url: url }
      public: post.get('permissions')['public']
      only_me: !post.get('permissions')['public'] && !permissible_entities.length && TentStatus.Helpers.isCurrentUserEntity(post.get('entity'))
      escaped:
        entity: encodeURIComponent( post.get 'entity' )
      formatted:
        reply_to_entities: @getReplyToEntities(post)
        permissible_entities: permissible_entities.join(', ')
        content:
          text: TentStatus.Helpers.simpleFormatText(
            TentStatus.Helpers.autoLinkText(TentStatus.Helpers.truncate(post.get('content')?.text, TentStatus.config.MAX_LENGTH, ''))
          )
        entity: TentStatus.Helpers.formatUrl post.get('entity')
        published_at: TentStatus.Helpers.formatRelativeTime post.get('published_at')
        full_published_at: TentStatus.Helpers.rawTime post.get('published_at')
      currentUserOwnsPost: TentStatus.Helpers.isCurrentUserEntity(post.get 'entity')
      max_chars: TentStatus.config.MAX_LENGTH
    }
    context

