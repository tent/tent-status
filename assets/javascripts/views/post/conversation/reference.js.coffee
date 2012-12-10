TentStatus.Views.ConversationReference = class ConversationReferenceView extends TentStatus.Views.ConversationComponent
  @view_name: 'conversation_reference'

  constructor: (options = {}) ->
    super

    @el.appendChild(@postView().el)

  detach: =>
    DOM.insertBefore(@postView().el, @parent_view.el)
    super

