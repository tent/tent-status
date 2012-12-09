TentStatus.Views.PostAction = class PostActionView extends TentStatus.View
  @view_name: 'post_action'

  constructor: ->
    super

    @text = {
      confirm: DOM.attr(@el, 'data-confirm')
    }

    DOM.on(@el, 'click', @confirmAction)

  confirmAction: =>
    return if @disabled
    return @performAction() unless @text.confirm
    @performAction() if confirm(@text.confirm)

  performAction: =>
    console.warn "#{@constructor.name}::performAction needs to be defined"
    console.log @el

