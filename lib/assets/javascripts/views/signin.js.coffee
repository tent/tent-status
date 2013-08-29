Marbles.Views.Signin = class SigninView extends Marbles.View
  @view_name: 'signin'
  @template_name: 'signin'

  initialize: (options = {}) =>
    @redirect_url = options.redirect_url

    @on 'init:SigninForm', @signinFormInit

    @render()

  signinFormInit: (signin_form) =>
    signin_form.on 'signin:success', @performRedirect

  performRedirect: =>
    window.location.href = @redirect_url

