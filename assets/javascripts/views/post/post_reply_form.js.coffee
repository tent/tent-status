Marbles.Views.PostReplyForm = class PostReplyFormView extends Marbles.Views.NewPostForm
  @template_name: '_post_reply_form'
  @view_name: 'post_reply_form'

  is_reply_form: true

  constructor: ->
    super

  toggle: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    Marbles.DOM.hide(@el)

  show: =>
    @visible = true
    setImmediate =>
      @constructor.instances.all[@_child_views.MentionsAutoCompleteTextarea?[0]]?.textarea_view?.focus()
    if @ready
      Marbles.DOM.show(@el)
    else
      @render()

  post: =>
    TentStatus.Models.Post.instances.all[@parent_view.post_cid]

