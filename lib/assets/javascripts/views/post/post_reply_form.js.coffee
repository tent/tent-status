Marbles.Views.PostReplyForm = class PostReplyFormView extends Marbles.Views.NewPostForm
  @template_name: '_post_reply_form'
  @view_name: 'post_reply_form'

  is_reply_form: true

  constructor: ->
    super

  initialRender: =>

  profileFetchSuccess: =>
    @render() if @visible

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

    # Focus textarea
    setImmediate =>
      @childViews('MentionsAutoCompleteTextareaContainer')?[0]?.childViews('MentionsAutoCompleteTextarea')?[0]?.focus()

    if @ready
      Marbles.DOM.show(@el)
    else
      @render()

  post: =>
    TentStatus.Models.Post.instances.all[@parent_view.post_cid]

