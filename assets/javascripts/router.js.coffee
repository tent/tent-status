class TentStatus.Router extends Backbone.Router
  @regex:
    named_param: /:\w+/g

  route: (route, name, callback) =>
    Backbone.history ||= new TentStatus.History
    unless _.isRegExp(route)
      param_names = @_routeParamNames(route)
      route = @_routeToRegExp(route)
    else
      param_names = []
    callback ?= @[name]

    Backbone.history.route route, (fragment, params) =>
      _.extend params, @_extractNamedParameters(route, fragment, param_names)
      args = [params]
      callback?.apply(@, args)
      @trigger.apply(@, ['route:' + name].concat(args))
      Backbone.history.trigger('route', @, name, args)
      @

  _routeParamNames: (route) =>
    _.map route.match(@constructor.regex.named_param), (name) => name.slice(1)

  _extractNamedParameters: (route, fragment, param_names) =>
    values = _.map @_extractParameters(route, fragment), ((val) -> decodeURIComponent(val))
    params = {}
    for name, index in param_names
      params[name] = values[index]
    params

