class TentStatus.History
  regex: {
    route_stripper: /^[#\/]/
    route_parts: /^([^?]*)(?:\?(.*))?$/ # 1: fragment, 2: query params
  }

  started: false
  handlers: []
  options: {}

  getFragment: (fragment = window.location.pathname) =>
    fragment += search if search = window.location.search

    fragment = fragment.substr(@options.root.length) if fragment.indexOf(@options.root) == -1
    fragment.replace(@regex.route_stripper, '')

  # start pushState handling
  start: (options = {}) =>
    throw new Backbone.Error("Backbone.history has already been started") if Backbone.History.started
    Backbone.history.started = true

    @options = _.extend { root: '/' }, @options, options
    @_hasPushState = !!(window.history && window.history.pushState)
    return unless @_hasPushState

    @fragment = @getFragment()

    # init back button binding
    DOM.on(window, 'popstate', @checkUrl)

    @loadUrl() unless @options.silent

  stop: =>
    DOM.off(window, 'popstate', @checkUrl)
    Backbone.history.started = false

  parseQueryParams: (query_string) =>
    @deserializeParams(query_string)

  serializeParams: (params) ->
    query = []
    for key,val of params
      val = val.join(',') if _.isArray(val)
      continue if val?.match(/^[\s\r\t\n]*$/)
      query.push "#{key}=#{encodeURIComponent(val)}"
    "?" + query.join("&")

  deserializeParams: (query_string) ->
    if query_string.substr(0, 1) == '?'
      query = query_string.substr(1, query_string.length).split('&')
    else
      query = query_string.split('&')

    params = {}
    for q in query
      [key,val] = q.split('=')
      continue unless val
      val = decodeURIComponent(val)
      val = val.split(',') if val.indexOf(',') != -1
      params[key] = val
    params

  # Add route to be tested when @fragment changes. Routes added later
  # may override previous routes.
  route: (route, callback) =>
    @handlers.unshift({route: route, callback: callback})

  # Check if URL has changed
  checkUrl: (e) =>
    current = @getFragment()
    return false if current is @fragment
    @loadUrl()

  # Attempt to load the current URL fragment
  # returns `true` if route matched, or `false` otherwise.
  loadUrl: =>
    fragment = @fragment = @getFragment()
    parts = fragment.match(@regex.route_parts)
    fragment = parts[1]
    query_params = @parseQueryParams(parts[2] || '')
    matched = _.any @handlers, (handler) =>
      if handler.route.test(fragment)
        handler.callback(fragment, query_params)
        true
    matched

  # Save a fragment into the history, or replace the URL state if the
  # 'replace' option is passed.
  # Expects the fragment to be properly URL-encoded.
  navigate: (fragment, options = {}) =>
    return false unless Backbone.history.started
    options = {trigger: true} if options is true
    fragment = (fragment || '').replace(@regex.route_stripper, '')
    return if fragment is @fragment

    fragment = @options.root + fragment if fragment.indexOf(@options.root) != 0
    @fragment = fragment

    unless @_hasPushState
      return (window.location.href = @options.root + fragment)

    window.history[if options.replace then 'replaceState' else 'pushState']({}, document.title, fragment)

    @loadUrl() if options.trigger

_.extend TentStatus.History::, TentStatus.Events

