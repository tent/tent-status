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

  detach: =>
    Marbles.DOM.removeNode(@el)
    super

  inReplyToJSON: (mention) =>
    return unless mention && mention.entity && mention.post
    {
      entity: mention.entity
      name: TentStatus.Helpers.formatUrlWithPath(mention.entity)
      url: TentStatus.Helpers.route('post', entity: mention.entity, post_id: mention.post)
    }

  getPermissibleEntities: (post, should_trim=true) =>
    if should_trim
      _.map post.get('permissions.entities') || [], (entity) =>
        TentStatus.Helpers.minimalEntity(entity)
    else
      post.get('permissions.entities') || []

  context: (post = @post()) =>
    permissible_entities = @getPermissibleEntities(post)

    post: post
    in_reply_to: @inReplyToJSON(post.get('mentioned_posts')[0])
    url: TentStatus.Helpers.route('post', entity: post.get('entity'), post_id: post.get('id'))
    only_me: !post.get('permissions.public') && !permissible_entities.length && TentStatus.Helpers.isCurrentUserEntity(post.get('entity'))
    current_user_owns_post: TentStatus.Helpers.isCurrentUserEntity(post.get('entity'))
    formatted:
      permissible_entities: permissible_entities.join(', ')
      content: TentStatus.Helpers.formatTentMarkdown(
        TentStatus.Helpers.truncate(post.get('content.text'), TentStatus.config.MAX_STATUS_LENGTH, ''),
        post.get('mentions')
      )

