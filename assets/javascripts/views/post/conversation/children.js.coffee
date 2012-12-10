TentStatus.Views.ConversationChildren = class ConversationChildrenView extends TentStatus.Views.ConversationComponent
  @template_name: '_conversation_children'
  @partial_names: ['_post'].concat(TentStatus.Views.Post.partial_names)
  @view_name: 'conversation_children'

  constructor: (options = {}) ->
    super

    @fetchPosts()

  fetchPosts: =>
    reference_post = @postView().post()
    reference_post.fetchChildren
      success: (posts) =>
        @appendRender(posts)

