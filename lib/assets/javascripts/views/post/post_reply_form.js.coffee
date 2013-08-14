Marbles.Views.PostReplyForm = class PostReplyFormView extends Marbles.Views.NewPostForm
  @template_name: '_post_reply_form'
  @view_name: 'post_reply_form'
  @model: TentStatus.Models.StatusReplyPost

  is_reply_form: true

  constructor: ->
    super

    @on 'ready', @initInlineMentions

  initInlineMentions: =>
    textarea_view = @textareaMentionsView()
    return unless textarea_view

    text = ""

    for entity in @post().conversation_entities
      profile = TentStatus.Models.MetaProfile.find(entity: entity)

      inline_mention = new TentStatus.InlineMentionsManager.InlineMention(
        entity: entity
        display_text: profile?.get('name') || TentStatus.Helpers.minimalEntity(entity)
      )

      text += inline_mention.toExpandedMarkdownString() + " "

    textarea_view.el.value = text
    textarea_view.inline_mentions_manager.updateMentions()

  # no initial render
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

    setImmediate @focusTextarea

    if @ready
      Marbles.DOM.show(@el)
    else
      @render()

  post: =>
    TentStatus.Models.Post.instances.all[@parentView().post_cid]

