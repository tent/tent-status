Marbles.Views.ConversationComponent = class ConversationComponentView extends TentStatus.View
  postView: =>
    @parent_view.parent_view

  postContext: =>
    _.extend Marbles.Views.Post::context(arguments...),
      is_conversation_view: true

  prependRender: =>
    Marbles.Views.PostsFeed::prependRender.apply(@, arguments)

  appendRender: =>
    Marbles.Views.PostsFeed::appendRender.apply(@, arguments)

  fetchPost: (params, callback) =>
    TentStatus.Models.Post.find(params, { success: callback })
