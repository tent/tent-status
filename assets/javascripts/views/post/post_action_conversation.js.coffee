TentStatus.Views.PostActionConversation = class PostActionConversationView extends TentStatus.Views.PostAction
  @view_name: 'post_action_conversation'

  performAction: =>
    if @visible
      @hide()
    else
      @show()

  postView: =>
    return view if @post_view_cid && (view = TentStatus.Views.Post.find(@post_view_cid))
    view = @
    while view.parent_view && view.constructor.view_name != 'post'
      view = view.parent_view
    @post_view_cid = view.cid
    view

  conversationView: =>
    return view if @conversation_view_cid && (view = TentStatus.Views.Conversation.find(@conversation_view_cid))
    post_view = @postView()
    view = new TentStatus.Views.Conversation parent_view: post_view
    @conversation_view_cid = view.cid
    view

  hide: =>
    view = @conversationView()
    view.destroy()
    delete @conversation_view_cid
    @visible = false

  show: =>
    @visible = true
    view = @conversationView()

