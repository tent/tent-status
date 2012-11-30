TentStatus.Views.PostAction = class PostActionView extends TentStatus.View
  @view_name: 'post_action'

  constructor: ->
    super

    DOM.on(@el, 'click', @performAction)

  performAction: =>
    console.warn "#{@constructor.name}::performAction needs to be defined"
    console.log @el

