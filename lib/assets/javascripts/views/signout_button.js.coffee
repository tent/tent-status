Marbles.Views.SignoutButton = class SignoutButtonView extends Marbles.View
  @view_name: 'signout_button'

  initialize: =>
    @signout_url = Marbles.DOM.attr(@el, 'data-url')
    @signout_redirect_url = Marbles.DOM.attr(@el, 'data-redirect_url')
    Marbles.DOM.on @el, 'click', @performSignout

  performSignout: (e) =>
    e?.preventDefault()

    new Marbles.HTTP {
      method: 'POST'
      url: @signout_url
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
      url: TentStatus.config.json_config_url
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

