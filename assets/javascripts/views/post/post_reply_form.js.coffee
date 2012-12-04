TentStatus.Views.PostReplyForm = class PostReplyFormView extends TentStatus.View
  @template_name: '_post_reply_form'
  @view_name: 'post_reply_form'

  constructor: ->
    super

    @elements = {}
    @text = {}

    @on 'ready', => @ready = true
    @on 'ready', @init

  toggle: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    DOM.hide(@el)

  show: =>
    @visible = true
    if @ready
      DOM.show(@el)
    else
      @render()

  post: =>
    TentStatus.Models.Post.instances.all[@parent_view.post_cid]

  context: =>
    post = @post()
    _.extend {}, super,
      max_chars: TentStatus.config.MAX_LENGTH
      id: post.id
      entity: post.entity

  init: =>
    @elements.submit = DOM.querySelector('input[type=submit]', @el)
    @elements.errors = DOM.querySelector('[data-errors_container]', @el)
    @elements.form = DOM.querySelector('form', @el)
    @elements.textarea = DOM.querySelector('textarea', @el)

    @text.disable_with = DOM.attr(@elements.submit, 'data-disable_with')

    @initCharCounter()
    @initValidation()

    DOM.on(@elements.form, 'submit', @submitWithValidation)

  initCharCounter: =>
    @elements.char_counter = DOM.querySelector('.char-limit', @el)
    @max_chars = TentStatus.config.MAX_LENGTH

    DOM.on @elements.textarea, 'keydown', (e) =>
      clearTimeout @_updateCharCounterTimeout
      return true if @frozen
      setTimeout @updateCharCounter, 20
      true

  initValidation: =>
    DOM.on @elements.textarea, 'keyup', (e) =>
      clearTimeout @_validateTimeout
      return if @frozen
      setTimeout @validate, 300

      @updateCharCounter()

      null

    @updateCharCounter()

  submitWithValidation: (e) =>
    e?.preventDefault()
    data = @buildPostAttributes()
    @submit(data) if @validate(data, {validate_empty:true})

    null

  submit: (data) =>
    @disableWith(@text.disable_with)
    data ?= @buildPostAttributes()
    TentStatus.Models.Post.create(data,
      error: (res, xhr) =>
        @enable()
        @showErrors([{ text: "Error: #{JSON.parse(xhr.responseText)?.error}" }])

      success: (post, xhr) =>
        @render()
        @hide()
    )

  disableWith: (text) =>
    @disable()
    @elements.submit.enable_with = @elements.submit.value
    @elements.submit.value = text

  disable: =>
    @frozen = true
    @elements.submit.disabled = true

  enable: =>
    @frozen = false
    @elements.submit.disabled = false
    if text = @elements.submit.enable_with
      @elements.submit.value = text
      delete @elements.submit.enable_with

  validate: (data, options = {}) =>
    return if @frozen
    data ?= @buildPostAttributes()
    errors = TentStatus.Models.Post.validate(data, options)
    @clearErrors()
    @showErrors(errors) if errors

    !errors

  clearErrors: =>
    for el in DOM.querySelectorAll('.error')
      DOM.removeClass(el, 'error')
    DOM.hide(@elements.errors)

  showErrors: (errors) =>
    error_messages = []
    for err in errors
      for name, msg of err
        input = DOM.querySelector("[name=#{name}]", @el)
        DOM.addClass(input, 'error')
        error_messages.push(msg)
    @elements.errors.innerHTML = error_messages.join("<br/>")
    DOM.show(@elements.errors)

  updateCharCounter: =>
    return if @frozen
    char_count = @elements.textarea.value?.length || 0
    delta = @max_chars - char_count

    @elements.char_counter.innerText = delta

    if delta < 0
      # limit exceeded
      DOM.addClass(@elements.char_counter, 'alert-error')
      @elements.submit.disabled = true
    else
      if delta == @max_chars
        # textarea empty
        @elements.submit.disabled = true
      else
        @elements.submit.disabled = false
      DOM.removeClass(@elements.char_counter, 'alert-error')

  buildPostAttributes: =>
    attrs = DOM.serializeForm(@elements.form)
    @buildPostMentionsAttributes(attrs)
    @buildPostPermissionsAttributes(attrs)
    attrs = _.extend attrs, {
      type: TentStatus.config.POST_TYPES.STATUS
    }
    attrs.content = { text: attrs.text }
    delete attrs.text
    attrs

  buildPostMentionsAttributes: (attrs) =>
    return unless attrs.text

    mentions = _.compact (_.map _.flatten(Array attrs.mentions), (entity) ->
      return unless entity
      { entity: entity }
    )
    delete attrs.mentions

    for i in TentStatus.Helpers.extractMentionsWithIndices(attrs.text)
      mentions.push { entity: i.entity }

    # in reply to mention
    if attrs.mentions_post_entity && attrs.mentions_post_id
      existing = false
      for m in mentions
        if m.entity == attrs.mentions_post_entity
          existing = true
          m.post = attrs.mentions_post_id
          break
      unless existing
        mentions.push { entity: attrs.mentions_post_entity, post: attrs.mentions_post_id }
        delete attrs.mentions_post_entity
        delete attrs.mentions_post_id

    attrs.mentions = mentions if mentions.length

  buildPostPermissionsAttributes: (attrs) =>
    permissions_view_cid = @_child_views.PermissionsFields?[0]
    if permissions_view_cid && (permissions_view = TentStatus.View.instances.all[permissions_view_cid])
      attrs.permissions = permissions_view.buildPermissions()
    else
      attrs.permissions = {
        public: true
      }

