#= require sha256
#= require jquery
#= require underscore
#= require http
#= require backbone
#= require ./backbone_sync
#= require hogan
#= require moment
#= require chosen.jquery
#= require_tree ./templates
#= require_self
#= require mac_auth
#= require ./paginator
#= require ./fetch_pool
#= require ./view
#= require ./router
#= require_tree ./helpers
#= require_tree ./views
#= require_tree ./routers
#= require_tree ./models
#= require_tree ./collections

@TentStatus ?= {
  api_root: '/api'
  url_root: '/'
  authenticated: false
  guest_authenticated: false
}
_.extend @TentStatus, Backbone.Events, {
  Views: {}
  Models: {}
  Collections: {}
  Routers: {}
  Helpers: {}
  csrf_token: $('meta[name="csrf-token"]').attr('content')
  PER_PAGE: 10

  config: {
    tent_api_root: new HTTP.URI(TentStatus.current_entity + '/tent')
    current_tent_api_root: new HTTP.URI(window.location.protocol + '//' + window.location.hostname + '/tent')
    domain_entity: new HTTP.URI(window.location.href)
    current_entity: new HTTP.URI(TentStatus.current_entity)
    post_types: ["https://tent.io/types/post/status/v0.1.0", "https://tent.io/types/post/repost/v0.1.0"]
    PER_PAGE: 10
    FETCH_INTERVAL: 3000
    MAX_FETCH_LATENCY: 30000
  }

  devWarning: (fn, msg) ->
    console.warn "<#{fn.constructor.name}> #{msg}"

  #############################
  #      Hogan Templates      #
  #############################
  fetchTemplate: (templatePath, callback) ->
    template = HoganTemplates[templatePath]
    return callback(template) if template

  ## Run Backbone
  backboneConfig: {
    pushState: true
    root: TentStatus.url_root
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
