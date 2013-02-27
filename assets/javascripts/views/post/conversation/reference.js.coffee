Marbles.Views.ConversationReference = class ConversationReferenceView extends Marbles.Views.ConversationComponent
  @view_name: 'conversation_reference'

  constructor: (options = {}) ->
    super

    @el.appendChild(@postView().el)

  detach: =>
    Marbles.DOM.insertBefore(@postView().el, @parent_view.el)
    super

