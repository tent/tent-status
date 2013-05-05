Marbles.Views.Post = class PostView extends Marbles.View
  @template_name: '_post'
  @partial_names: ['_post_inner', '_post_inner_actions']
  @view_name: 'post'

  constructor: (options = {}) ->
    super(_.extend(options, {render_method: 'replace'}))

    @post_cid = Marbles.DOM.attr(@el, 'data-post_cid')

    @bindEl()
    @on 'ready', @bindEl

  bindEl: =>
    Marbles.DOM.on @el, 'click', @focus

  focus: (e) =>
    @constructor.trigger('focus', @, e)

  post: =>
    Marbles.Model.instances.all[@post_cid]

  hide: =>
    Marbles.DOM.hide(@el)

  inReplyToJSON: (mention) =>
    return unless mention && mention.entity && mention.post
    {
      name: TentStatus.Helpers.formatUrlWithPath(mention.entity),
      url: TentStatus.Helpers.entityPostUrl(mention.entity, mention.post)
    }

  getPermissibleEntities: (post, should_trim=true) =>
    _entities = []
    for entity, can_see of (post.get('permissions.entities') || {})
      continue unless can_see
      entity = TentStatus.Helpers.minimalEntity(entity) if should_trim
      _entities.push(entity)
    _entities

  context: (post = @post()) =>
    permissible_entities = @getPermissibleEntities(post)
    context = _.extend super, post.toJSON(), {
      cid: post.cid
      profile_cid: post.profile_cid
      is_repost: post.get('is_repost')
      in_reply_to: @inReplyToJSON(post.get('mentioned_posts')[0])
      url: TentStatus.Helpers.postUrl(post)
      profileUrl: TentStatus.Helpers.entityProfileUrl(post.get 'entity')
      public: post.get('permissions.public')
      only_me: !post.get('permissions.public') && !permissible_entities.length && TentStatus.Helpers.isCurrentUserEntity(post.get('entity'))
      current_user_owns_post: TentStatus.Helpers.isCurrentEntity(post.get('entity'))
      formatted:
        permissible_entities: permissible_entities.join(', ')
        content:
          text: TentStatus.Helpers.simpleFormatText(
            TentStatus.Helpers.autoLinkText(TentStatus.Helpers.truncate(post.get('content')?.text, TentStatus.config.MAX_LENGTH, ''), entity_whitelist: _.map( post.get('mentions') || [], (m) -> m.entity ))
          )
        entity: TentStatus.Helpers.formatUrl post.get('entity')
        published_at: TentStatus.Helpers.formatRelativeTime post.get('published_at')
        full_published_at: TentStatus.Helpers.rawTime post.get('published_at')
    }
    context
