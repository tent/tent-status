class TentStatus.Router extends Backbone.Router
  route: (route, name, callback) =>
    Backbone.history ||= new TentStatus.History
    route = @_routeToRegExp(route) unless _.isRegExp(route)
    callback ?= @[name]

    Backbone.history.route route, (fragment, params) =>
      args = _.map @_extractParameters(route, fragment), (arg) -> decodeURIComponent(arg)
      args.push(params)
      callback?.apply(@, args)
      @trigger.apply(@, ['route:' + name].concat(args))
      Backbone.history.trigger('route', @, name, args)
      @

