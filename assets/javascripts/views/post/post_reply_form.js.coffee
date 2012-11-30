TentStatus.Views.PostReplyForm = class PostReplyFormView extends TentStatus.View
  @template_name: '_post_reply_form'
  @view_name: 'post_reply_form'

  constructor: ->
    super

    @elements = {}

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

  context: =>
    _.extend {}, super,
      max_chars: TentStatus.config.MAX_LENGTH

  init: =>
    @elements.submit = DOM.querySelector('input[type=submit]', @el)
    @elements.errors = DOM.querySelector('[data-errors_container]', @el)
    @elements.form = DOM.querySelector('form', @el)

    @initCharCounter()
    @initValidation()

  initCharCounter: =>
    @elements.char_counter = DOM.querySelector('.char-limit', @el)
    @max_chars = TentStatus.config.MAX_LENGTH

  initValidation: =>
    @elements.textarea = DOM.querySelector('textarea', @el)

    DOM.on @elements.textarea, 'keyup', (e) =>
      clearTimeout @_validateTimeout
      return if @frozen
      setTimeout @validate, 300

      @updateCharCounter()

      null

    @updateCharCounter()

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
    attrs.content = attrs.text
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

    attrs.mentions = mentions if mentions.length

  buildPostPermissionsAttributes: (attrs) =>
    permissions_view_cid = @_child_views.PermissionsFields?[0]
    if permissions_view_cid && (permissions_view = TentStatus.View.instances.all[permissions_view_cid])
      attrs.permissions = permissions_view.buildPermissions()
    else
      attrs.permissions = {
        public: true
      }

