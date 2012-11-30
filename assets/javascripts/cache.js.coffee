class Cache
  constructor: ->
    window.addEventListener("message", @receiveMessage, false)

  receiveMessage: (event) =>
    origin_uri = new HTTP.URI(event.origin)
    self_uri = new HTTP.URI(window.location.href)

    return unless origin_uri.base_host == self_uri.base_host &&
                  origin_uri.port == self_uri.port

    msg = event.data || {}
    switch msg.action
      when 'init'
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
    @postMessage {
      action: 'set'
      key: key
      value: value
      options: options
    }

  get: (key, callback) =>
    return unless callback
    @once "receive:#{key}", callback
    @postMessage {
      action: 'get'
      key: key
    }

  remove: (key) =>
    @postMessage {
      action: 'delete'
      key: key
    }

_.extend Cache::, TentStatus.Events
TentStatus.Cache = new Cache

