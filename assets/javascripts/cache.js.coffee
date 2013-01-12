class Cache extends TentStatus.Events
  constructor: ->
    @loaded = false
    window.addEventListener("message", @receiveMessage, false)

  receiveMessage: (event) =>
    origin_uri = new HTTP.URI(event.origin)
    self_uri = new HTTP.URI(window.location.href)

    return unless origin_uri.base_host == self_uri.base_host &&
                  origin_uri.port == self_uri.port

    msg = event.data || {}
    switch msg.action
      when 'init'
        @loaded = true
        @iframe = event.source
        @trigger 'init'
      when 'trigger'
        @trigger msg.event, msg.event_args...

  postMessage: (msg) =>
    unless @iframe
      @once 'init', => @postMessage(msg)
      return

    try
      @iframe.postMessage(msg, '*')
    catch e
      setTimeout (-> throw e), 0

  set: (key, value, options = {}) =>
    return unless key && value
    @setLocal(key, value, options) unless @loaded
    @postMessage {
      action: 'set'
      key: key
      value: value
      options: options
    }

  get: (key, callback) =>
    return unless callback
    return @getLocal(key, callback) unless @loaded
    @once "receive:#{key}", callback
    @postMessage {
      action: 'get'
      key: key
    }

  remove: (key) =>
    @removeLocal(key) unless @loaded
    @postMessage {
      action: 'delete'
      key: key
    }

  LOCAL_CACHE: {}

  setLocal: (key, value, options = {}) =>
    @LOCAL_CACHE[key] = value

  getLocal: (key, callback) =>
    callback(@LOCAL_CACHE[key])

  removeLocal: (key) =>
    delete @LOCAL_CACHE[key]

TentStatus.Cache = new Cache

