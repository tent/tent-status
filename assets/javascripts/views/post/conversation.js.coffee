TentStatus.Views.Conversation = class ConversationView extends TentStatus.View
  @template_name: 'conversation'
  @view_name: 'conversation'

  constructor: (options = {}) ->
    super(_.extend({render_method:'replace'}, options))

    @el = document.createElement('div')
    DOM.insertBefore(@el, @parent_view.el)

    @render()

  destroy: =>
    @detachChildViews()
    DOM.removeNode(@el)
    @detach()

