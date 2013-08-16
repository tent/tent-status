Marbles.Views.ConversationChildren = class ConversationChildrenView extends Marbles.Views.ConversationComponent
  @template_name: '_conversation_children'
  @partial_names: ['_post'].concat(Marbles.Views.Post.partial_names)
  @view_name: 'conversation_children'

  constructor: (options = {}) ->
    super

    # Replying to a post with the conversation view open prepends it to the replies feed
    TentStatus.Models.StatusPost.on 'create:success', (post, xhr) =>
      return unless post.get('type') is TentStatus.config.POST_TYPES.STATUS_REPLY
      conversation_post = @post()
      return unless _.any post.get('mentions') || [], (m) =>
        conversation_post.get('entity') == m.entity && conversation_post.get('id') == m.post && (!m.version || conversation_post.get('version.id') == m.version)
      @prependRender([post])

    @fetchPosts()

  fetchPosts: (options = {}) =>
    reference_post = @post()
    reference_post.fetchReplies?(_.extend(
      success: (posts) =>
        @render(posts)
    , options))

