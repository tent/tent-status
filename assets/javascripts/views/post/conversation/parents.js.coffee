TentStatus.Views.ConversationParents = class ConversationParentsView extends TentStatus.Views.ConversationComponent
  @template_name: '_conversation_parents'
  @partial_names: ['_post'].concat(TentStatus.Views.Post.partial_names)
  @view_name: 'conversation_parents'

  constructor: (options = {}) ->
    super

    @fetchPosts()

  fetchPosts: =>
    reference_post = @postView().post()
    for m in reference_post.postMentions()
      do (m) =>
        @fetchPost {entity: m.entity, id: m.post}, (post) =>
          @prependRender([post])

