TentStatus.Views.ParentPostLink = class ParentPostLinkView extends TentStatus.View
  @view_name: 'parent_post_link'

  constructor: (options = {}) ->
    super

    DOM.on @el, 'click', (e) =>
      return true unless @conversationParentsView()
      e.preventDefault()
      @loadParentPost()
      false

  conversationParentsView: => @findParentView('conversation_parents')

  loadParentPost: =>
    post = @parent_view.post()
    mention = post.postMentions()[0]
    @conversationParentsView().fetchPost {entity: mention.entity, id: mention.post}, (post) =>
      @conversationParentsView().prependRender([post])
