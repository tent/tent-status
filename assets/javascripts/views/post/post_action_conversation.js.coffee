Marbles.Views.PostActionConversation = class PostActionConversationView extends Marbles.Views.PostAction
  @view_name: 'post_action_conversation'

  performAction: =>
    if view = @findParentView('conversation_parents')
      post_view = @findParentView('post')
      reference_post = post_view.post()

      el = post_view.el
      offset_top = el.offsetTop - window.scrollY

      unless @visible
        @visible = true

        view.once 'ready', =>
          delta = (el.offsetTop - window.scrollY) - offset_top
          window.scrollTo(window.scrollX, window.scrollY + delta)

        view.fetchPosts(reference_post) if reference_post
      return

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

    el = view.parent_view.el
    offsetTop = el.offsetTop - window.scrollY

    view.destroy()
    delete @conversation_view_cid
    @visible = false

    delta = (el.offsetTop - window.scrollY) - offsetTop
    window.scrollTo(window.scrollX, window.scrollY + delta)

  show: =>
    @visible = true
    view = @conversationView()

    el = view.parent_view.el
    offsetTop = el.offsetTop - window.scrollY

    view.on 'init:ConversationReference', (reference_view) =>
      delta = (el.offsetTop - window.scrollY) - offsetTop
      window.scrollTo(window.scrollX, window.scrollY + delta)

    view.on 'init:ConversationParents', (parents_view) =>
      parents_view.once 'ready', =>
        delta = (el.offsetTop - window.scrollY) - offsetTop
        window.scrollTo(window.scrollX, window.scrollY + delta)


