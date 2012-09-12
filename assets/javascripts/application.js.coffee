#= require jquery
#= require underscore
#= require http
#= require backbone
#= require ./backbone_sync
#= require hogan
#= require moment
#= require chosen.jquery
#= require_self
#= require ./view
#= require ./router
#= require_tree ./helpers
#= require_tree ./views
#= require_tree ./routers
#= require_tree ./models
#= require_tree ./collections

@StatusPro ?= {}
_.extend @StatusPro, Backbone.Events, {
  Views: {}
  Models: {}
  Collections: {}
  Routers: {}
  Helpers: {}

  devWarning: (fn, msg) ->
    console.warn "<#{fn.constructor.name}> #{msg}"

  #############################
  #      Hogan Templates      #
  #############################
  _templates: {}
  fetchTemplate: (templatePath, callback) ->
    template = @_templates[templatePath]
    return callback(template) if template

    HTTP.get "/assets/#{ templatePath }.html.mustache", (template) =>
      @_templates[templatePath] = Hogan.compile template
      callback(@_templates[templatePath])

  ## Run Backbone
  backboneConfig: {
    pushState: true
    root: '/'
  }
  run: ->
    Backbone.history?.start @backboneConfig

    @ready = true
    @trigger 'ready'

  #############################
  #       Route Lookup        #
  #############################

  # returns object: { 'router:action': '/path/to/action/:foo', ... }
  routeTable: ->
    routeTable = {}
    for name, o of @Routers
      for p, a of o.routes
        routeTable["#{name}:#{a}"] = p
    routeTable

  # key: 'router:action'
  # params: object (named url params)
  #
  # returns object: {
  #   trigger: # function (navigates to route)
  #   url: # evaluated url
  #   key: # original key argument ('router:action')
  # }
  lookupRoute: (key, params = {}) ->
    routeTable = @routeTable()
    match = routeTable[key]
    return unless match

    router = @Routers[key.split(':')[0]]
    url = match
    _.each url.match(/:[^\/]+/g), (segment) =>
      url = url.replace(segment, params[segment.slice(1, segment.length)])

    {
      trigger: =>
        router.navigate(url, { trigger: true })
      url: "/" + url
      key: key
    }

  # pattern (standard backbone route pattern): e.g. 'path/to/:foo'
  # path (window.location.pathname): e.g. "/path/to/baz"
  #
  # returns hash of params in given path, e.g. { foo: 'baz' }
  paramsForPatternAndPath: (pattern, path) ->
    unless path
      if Backbone.history._wantsHashChange and !Backbone.history._hasPushState
        path = window.location.hash
      else
        path = window.location.pathname
        path = path.replace(new RegExp("^#{ Backbone.history.options.root }"), "")

    parts = pattern.split("/")
    pathParts = path.replace(/^\//, '').split("/")

    params = {}
    for p, index in parts
      if p.slice(0, 1) == ":"
        params[p.slice(1, p.length)] = pathParts[index]
    params
}
