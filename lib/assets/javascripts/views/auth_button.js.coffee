Marbles.Views.AuthButton = class AuthButtonView extends Marbles.View
  @view_name: 'auth_button'

  initialize: =>
    Marbles.DOM.on @el, 'click', @performAction

    if TentStatus.config.authenticated
      @actionFn = @performSignout
      Marbles.DOM.setAttr(@el, 'title', Marbles.DOM.attr(@el, 'data-signout-title'))
    else
      @actionFn = @redirectToSignin
      Marbles.DOM.setAttr(@el, 'title', Marbles.DOM.attr(@el, 'data-signin-title'))

  performAction: => @actionFn()

  performSignout: (e) =>
    e?.preventDefault()

    new Marbles.HTTP {
      method: 'POST'
      url: TentStatus.config.SIGNOUT_URL
      middleware: [Marbles.HTTP.Middleware.WithCredentials]
      callback: (res, xhr) =>
        @signoutRedirect()
    }

  redirectToSignin: =>
    Marbles.history.navigate('/signin', trigger: true)

  signoutRedirect: =>
    window.location.href = TentStatus.config.SIGNOUT_REDIRECT_URL

