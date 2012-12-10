TentStatus.Views.ConversationComponent = class ConversationComponentView extends TentStatus.View
  postView: =>
    @parent_view.parent_view

  postContext: =>
    _.extend TentStatus.Views.Post::context(arguments...),
      is_conversation_view: true

  prependRender: =>
    TentStatus.Views.PostsFeed::prependRender.apply(@, arguments)

  appendRender: =>
    TentStatus.Views.PostsFeed::appendRender.apply(@, arguments)

  fetchPost: (params, callback) =>
    TentStatus.Models.Post.find(params, { success: callback })
