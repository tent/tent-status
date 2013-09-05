Marbles.Views.PostReplyForm = class PostReplyFormView extends Marbles.Views.NewPostForm
  @template_name: '_post_reply_form'
  @view_name: 'post_reply_form'
  @model: TentStatus.Models.StatusReplyPost

  is_reply_form: true

  constructor: ->
    super

    @on 'ready', @initInlineMentions

  fetchProfile: (entity, callback) =>
    profile = TentStatus.Models.MetaProfile.find(entity: entity)
    profile ?= new TentStatus.Models.MetaProfile(entity: entity)

    if profile.get('id')
      callback(profile)
    else
      profile.fetch(
        complete: =>
          callback(profile)
      )

  initInlineMentions: =>
    textarea_view = @textareaMentionsView()
    return unless textarea_view

    Marbles.DOM.setAttr(textarea_view.el, 'disabled', 'disabled')

    text = ""

    entities = @post().conversation_entities
    entities_display_text = {}
    num_pending_profiles = entities.length

    entityCompleteFn = (entity, profile) =>
      inline_mention = new TentStatus.InlineMentionsManager.InlineMention(
        entity: entity
        display_text: profile?.get('name') || TentStatus.Helpers.minimalEntity(entity)
      )

      entities_display_text[entity] = inline_mention.toExpandedMarkdownString()

      num_pending_profiles -= 1
      if num_pending_profiles <= 0
        for entity in entities
          text += entities_display_text[entity] + " "

        textarea_view.el.value = text
        Marbles.DOM.removeAttr(textarea_view.el, 'disabled')

        textarea_view.inline_mentions_manager.updateMentions()

    for entity in entities
      do (entity) =>
        @fetchProfile entity, (profile) =>
          entityCompleteFn(entity, profile)

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

