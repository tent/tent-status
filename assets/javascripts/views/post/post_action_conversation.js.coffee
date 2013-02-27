Marbles.Views.PostActionConversation = class PostActionConversationView extends Marbles.Views.PostAction
  @view_name: 'post_action_conversation'

  performAction: =>
    if @visible
      @hide()
    else
      @show()

  conversationView: =>
    return view if @conversation_view_cid && (view = Marbles.Views.Conversation.find(@conversation_view_cid))
    post_view = @postView()
    view = new Marbles.Views.Conversation parent_view: post_view
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

