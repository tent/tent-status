Marbles.Views.ConversationChildren = class ConversationChildrenView extends Marbles.Views.ConversationComponent
  @template_name: '_conversation_children'
  @partial_names: ['_post'].concat(Marbles.Views.Post.partial_names)
  @view_name: 'conversation_children'

  constructor: (options = {}) ->
    super

    @fetchPosts()

  fetchPosts: =>
    reference_post = @post()
    reference_post.fetchReplies(
      success: (posts) =>
        @appendRender(posts)
    )

