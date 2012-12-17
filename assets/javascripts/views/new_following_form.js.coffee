TentStatus.Views.NewFollowingForm = class NewFollowingFormView extends TentStatus.View
  @template_name: '_new_following_form'
  @view_name: 'new_following_form'

  constructor: (options = {}) ->
    super

    @elements = {}

    @on 'ready', @init

    @render()

  init: =>
    @elements.form = DOM.querySelector('form', @el)
    @elements.input = DOM.querySelector('input[name=entity]', @el)
    @elements.submit = DOM.querySelector('input[type=submit]', @el)
    @elements.errors = DOM.querySelector('.alert-error', @el)

    DOM.on(@elements.form, 'submit', @submit)
    DOM.on(@elements.submit, 'click', @submit)

  submit: (e) =>
    e?.preventDefault()
    return if @frozen

    entity = @buildEntity(@elements.input.value)
    data = {entity: entity}

    @clearErrors()
    return unless @validate(data)
    @disable()

    TentStatus.Models.Following.create data,
      error: (res, xhr) =>
        @enable()
        @showErrors([{ entity: "Error: #{res?.error}" }])
      success: (following) =>
        @reset()

  reset: =>
    @clearErrors()
    @enable()
    @elements.input.value = ""

  disable: =>
    @frozen = true
    @elements.submit.disabled = true
    @elements.form.disabled = true

  enable: =>
    @frozen = false
    @elements.submit.disabled = false
    @elements.form.disabled = false

  validate: (data, options = {}) =>
    return if @frozen
    errors = TentStatus.Models.Following.validate(data, options)
    @clearErrors()
    @showErrors(errors) if errors

    !errors

  clearErrors: =>
    for el in DOM.querySelectorAll('.error', @el)
      DOM.removeClass(el, 'error')
    DOM.hide(@elements.errors)

  showErrors: (errors) =>
    error_messages = []
    for error in errors
      for name, msg of error
        input = DOM.querySelector("[name=#{name}]", @el)
        DOM.addClass(input, 'error')
        error_messages.push(msg)
    @elements.errors.innerHTML = error_messages.join("<br/>")
    DOM.show(@elements.errors)

  buildEntity: (entity) =>
    return unless (m = entity.match(/^(https?:\/\/)?([^\/]+)(.*?)$/))
    parts = {
      scheme: m[1]
      domain: m[2]
      rest: m[3] || ""
    }

    if TentStatus.config.tent_host_domain
      if parts.domain.match /^[a-z0-9]{2,30}$/
        # valid host username
        parts.shceme = TentStatus.config.tent_host_scheme
        parts.domain += ".#{TentStatus.config.tent_host_domain}"
      else if parts.domain.match(new RegExp(RegExp.escape(TentStatus.config.tent_host_domain) + "$"))
        parts.scheme = TentStatus.config.tent_host_scheme

    parts.scheme ?= 'http://'
    entity = parts.scheme + parts.domain + parts.rest

    entity

