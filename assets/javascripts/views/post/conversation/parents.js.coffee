TentStatus.Views.ConversationParents = class ConversationParentsView extends TentStatus.Views.ConversationComponent
  @template_name: '_conversation_parents'
  @partial_names: ['_post'].concat(TentStatus.Views.Post.partial_names)
  @view_name: 'conversation_parents'

  constructor: (options = {}) ->
    super

    @fetchPosts()

  fetchPosts: =>
    reference_post = @postView().post()
    reference_post.fetchMentions
      success: (mentions) =>
        for m in mentions
          do (m) =>
            @fetchPost {entity: m.entity, id: m.post}, (post) =>
              @prependRender([post])

