#= require hmac_sha256
#= require jquery
#= require underscore
#= require store
#= require http
#= require backbone
#= require ./backbone_sync
#= require hogan
#= require moment
#= require chosen.jquery
#= require_tree ./templates
#= require_self
#= require mac_auth
#= require ./events
#= require ./cache
#= require ./paginator
#= require ./fetch_pool
#= require ./view
#= require ./router
#= require_tree ./helpers
#= require_tree ./views
#= require_tree ./routers
#= require ./model
#= require_tree ./models
#= require_tree ./collections
#= require iphone

@TentStatus ?= {
  api_root: ''
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
    tent_host_api_root: TentStatus.tent_host_api_root
    tent_api_root: new HTTP.URI(TentStatus.tent_api_root) if TentStatus.tent_api_root
    current_tent_api_root: new HTTP.URI(TentStatus.domain_tent_api_root) if TentStatus.domain_tent_api_root
    tent_host_domain: TentStatus.tent_host_domain
    tent_host_domain_tent_api_path: '/tent'
    tent_proxy_root: new HTTP.URI(TentStatus.tent_proxy_root)
    domain_entity: new HTTP.URI(TentStatus.domain_entity) if TentStatus.domain_entity
    domain_tent_api_root: new HTTP.URI(TentStatus.domain_tent_api_root) if TentStatus.domain_tent_api_root
    current_entity: new HTTP.URI(TentStatus.current_entity) if TentStatus.current_entity
    post_types: ["https://tent.io/types/post/status/v0.1.0", "https://tent.io/types/post/repost/v0.1.0"]
    PER_PAGE: 10
    FETCH_INTERVAL: 3000
    MAX_FETCH_LATENCY: 30000
    URL_TRIM_LENGTH: 30
    MAX_LENGTH: 256
    default_avatar: 'http://dr49qsqhb5y4j.cloudfront.net/default1.png'
  }

  isAppSubdomain: =>
    TentStatus.config.tent_host_domain and window.location.hostname == "app.#{TentStatus.config.tent_host_domain}"

  redirectToGlobalFeed: =>
    TentStatus.Routers.posts.navigate('/global', {trigger:true})

  setPageTitle: (title, options={}) =>
    @base_title ?= document.title
    base_title = if options.includes_base_title then "" else " - #{@base_title}"
    title = title + base_title if title
    title ?= base_title
    document.title = title

  devWarning: (fn, msg) ->
    console?.warn "<#{fn.constructor.name}> #{msg}"

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

    @on 'ready', @fetchCurrentProfile

    @ready = true
    @trigger 'ready'

    @on 'loading:start', @showLoadingIndicator
    @on 'loading:complete', @hideLoadingIndicator

  showLoadingIndicator: ->
    @_num_running_requests ?= 0
    @_num_running_requests += 1
    @Views.loading_indicator.show()

  hideLoadingIndicator: ->
    @_num_running_requests ?= 1
    @_num_running_requests -= 1
    @Views.loading_indicator.hide() if @_num_running_requests == 0

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

  fetchCurrentProfile: ->
    entity = @config.current_entity.toStringWithoutSchemePort()
    cache_key = "profile:#{entity}"
    expires_at_cache_key = "profile:#{entity}:expires_at"

    expires_at = @Cache.get(expires_at_cache_key)
    expires_at = new Date(expires_at) if expires_at
    now = new Date * 1

    if expires_at and expires_at > now and (profile = @Cache.get(cache_key))
      @Models.profile = new @Models.profile.constructor(profile)
      @trigger 'profile:fetch:success'
    else
      @Models.profile.fetch
        success: =>
          @trigger 'profile:fetch:success'
          @Cache.set cache_key, @Models.profile.toJSON(), {saveToLocalStorage:true}
          @Cache.set expires_at_cache_key, ((new Date * 1) + 86400000), {saveToLocalStorage:true}

}
