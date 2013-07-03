Marbles.Views.SignoutButton = class SignoutButtonView extends Marbles.View
  @view_name: 'signout_button'

  initialize: =>
    Marbles.DOM.on @el, 'click', @performSignout

  performSignout: (e) =>
    e?.preventDefault()

    new Marbles.HTTP {
      method: 'POST'
      url: TentStatus.config.SIGNOUT_URL
      middleware: [{
        processRequest: (request) ->
          request.request.xmlhttp.withCredentials = true
      }]
      callback: (res, xhr) =>
        @refreshConfigJSON()
    }

  refreshConfigJSON: =>
    new Marbles.HTTP {
      method: 'GET'
      url: TentStatus.config.SIGNOUT_REDIRECT_URL
      middleware: [{
        processRequest: (request) ->
          request.request.xmlhttp.withCredentials = true
      }]
      headers: {
        'Cache-Control': 'no-cache'
        'Pragma': 'no-cache'
      }
      callback: (res, xhr) =>
        @signoutRedirect()
    }

  signoutRedirect: =>
    window.location.href = @signout_redirect_url

