Marbles.Views.ConversationReference = class ConversationReferenceView extends Marbles.Views.ConversationComponent
  @view_name: 'conversation_reference'

  constructor: (options = {}) ->
    super

    @el.appendChild(@postView().el)

    unless @postView().post()?.get('is_repost')
      post_container_el = Marbles.DOM.querySelector('.post-container', @el)
      @repost_visibility_el = @postView().el.repost_visibility_el ?= document.createElement('div')
      Marbles.DOM.setAttr(@repost_visibility_el, 'data-view', 'RepostVisibility')
      post_container_el.appendChild(@repost_visibility_el)
      @bindViews()

  detach: =>
    Marbles.DOM.insertBefore(@postView().el, @parentView().el)
    Marbles.DOM.removeNode(@repost_visibility_el) if @repost_visibility_el
    super

