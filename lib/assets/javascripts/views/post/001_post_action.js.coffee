Marbles.Views.PostAction = class PostActionView extends Marbles.View
  @view_name: 'post_action'

  constructor: ->
    super

    @text = {
      confirm: Marbles.DOM.attr(@el, 'data-confirm')
    }

    Marbles.DOM.on(@el, 'click', @confirmAction)

  confirmAction: =>
    return if @disabled
    return @performAction() unless @text.confirm
    @performAction() if confirm(@text.confirm)

  performAction: =>
    console.warn "#{@constructor.name}::performAction needs to be defined"
    console.log @el

  postView: => @findParentView('post')

