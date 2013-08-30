CSS_VALID_CLASS = "has-success"
CSS_INVALID_CLASS = "has-error"
CSS_HIDDEN_CLASS = "hidden"
CSS_ALERT_ERROR_CLASS = "alert-error"
CSS_ALERT_INFO_CLASS = "alert-info"

Marbles.Views.SigninForm = class SigninFormView extends Marbles.View
  @view_name: 'signin_form'

  initialize: =>
    @fields = {
      username: new Field(Marbles.DOM.querySelector('[name=username]', @el))
      passphrase: new Field(Marbles.DOM.querySelector('[name=passphrase]', @el))
    }

    @alert_el = Marbles.DOM.querySelector('.alert', @el)

    Marbles.DOM.on @el, 'submit', @handleSubmit

  handleSubmit: (e) =>
    e?.preventDefault()

    for name, field of @fields
      field.clearInvalid()

    @showInfo 'Please wait...'

    new Marbles.HTTP(
      method: 'POST'
      url: TentStatus.config.SIGNIN_URL
      body: {
        username: @fields.username.getValue()
        passphrase: @fields.passphrase.getValue()
      }
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
      middleware: [
        Marbles.HTTP.Middleware.WithCredentials,
        Marbles.HTTP.Middleware.FormEncoded,
        Marbles.HTTP.Middleware.SerializeJSON
      ]
      callback: @submitComplete
    )

  submitComplete: (res, xhr) =>
    if xhr.status == 200
      @handleSuccess()
    else
      @handleFailure(res, xhr)

  handleSuccess: =>
    @hideAlert()

    for name, field of @fields
      field.markValid()

    @trigger 'signin:success'

  handleFailure: (res) =>
    @showError(res.error || 'Something went wrong')

    for name in (res.fields || Object.keys(@fields))
      @fields[name]?.markInvalid()

  showError: (msg) =>
    Marbles.DOM.setInnerText(@alert_el, msg)

    Marbles.DOM.removeClass(@alert_el, CSS_ALERT_INFO_CLASS)
    Marbles.DOM.addClass(@alert_el, CSS_ALERT_ERROR_CLASS)
    Marbles.DOM.removeClass(@alert_el, CSS_HIDDEN_CLASS)

  showInfo: (msg) =>
    Marbles.DOM.setInnerText(@alert_el, msg)

    Marbles.DOM.removeClass(@alert_el, CSS_ALERT_ERROR_CLASS)
    Marbles.DOM.addClass(@alert_el, CSS_ALERT_INFO_CLASS)
    Marbles.DOM.removeClass(@alert_el, CSS_HIDDEN_CLASS)

  hideAlert: =>
    Marbles.DOM.addClass(@alert_el, CSS_HIDDEN_CLASS)

class Field
  constructor: (@el) ->
    @container_el = Marbles.DOM.parentQuerySelector(@el, '.control-group')
    @error_msg_el = Marbles.DOM.querySelector('.error-msg', @container_el)

  getValue: =>
    @el.value

  clearInvalid: =>
    Marbles.DOM.removeClass(@container_el, CSS_INVALID_CLASS)

  markValid: =>
    Marbles.DOM.removeClass(@container_el, CSS_INVALID_CLASS)
    Marbles.DOM.addClass(@container_el, CSS_VALID_CLASS)

  markInvalid: =>
    Marbles.DOM.removeClass(@container_el, CSS_VALID_CLASS)
    Marbles.DOM.addClass(@container_el, CSS_INVALID_CLASS)

