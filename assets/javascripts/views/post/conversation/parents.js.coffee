Marbles.Views.ConversationParents = class ConversationParentsView extends Marbles.Views.ConversationComponent
  @template_name: '_conversation_parents'
  @partial_names: ['_post'].concat(Marbles.Views.Post.partial_names)
  @view_name: 'conversation_parents'

  constructor: (options = {}) ->
    super

    setImmediate @fetchPosts

  postContext: =>
    _.extend super,
      is_conversation_view_parent: true

  fetchPosts: (reference_post) =>
    reference_post ?= @post()
    mentions = reference_post.postMentions()

    for m in mentions
      do (m) =>
        @fetchPost {entity: m.entity, id: m.post}, (post) =>
          @prependRender([post])
          @trigger('ready')

