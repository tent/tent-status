Marbles.Views.ConversationParents = class ConversationParentsView extends Marbles.Views.ConversationComponent
  @template_name: '_conversation_parents'
  @partial_names: ['_post'].concat(Marbles.Views.Post.partial_names)
  @view_name: 'conversation_parents'

  constructor: (options = {}) ->
    super

    setImmediate @fetchPosts

  fetchPosts: =>
    reference_post = @postView().post()
    mentions = reference_post.postMentions()

    num_remaining = mentions.length
    complete = =>
      num_remaining--
      @trigger('ready') if num_remaining == 0

    for m in mentions
      do (m) =>
        @fetchPost {entity: m.entity, id: m.post}, (post) =>
          @prependRender([post])
          complete()

