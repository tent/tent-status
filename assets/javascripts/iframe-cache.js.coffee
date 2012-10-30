#= require moment
#= require underscore
#= require uri
#= require store

class Cache
  CACHE: {}

  constructor: ->
    window.addEventListener("message", @receiveMessage, false)
    @main_app = window.parent
    @postMessage({ action: "init" })

  receiveMessage: (event) =>
    origin_uri = new HTTP.URI(event.origin)
    self_uri = new HTTP.URI(window.location.href)

    return unless origin_uri.base_host == self_uri.base_host &&
                  origin_uri.port == self_uri.port

    msg = event.data || {}
    switch msg.action
      when 'set'
        @set msg.key, msg.value, msg.options
      when 'get'
        @get msg.key
      when 'delete'
        @remove msg.key

  postMessage: (msg) =>
    @main_app.postMessage(msg, '*')

  trigger: (event, args...) =>
    @postMessage {
      action: 'trigger'
      event: event
      event_args: args
    }

  wrapValueWithExpiry: (value) =>
    expires = moment().add('minutes', 30) * 1
    { val: value, exp: expires }

  unwrapValueWithExpiry: (value) =>
    return unless value
    expires = value.exp
    return unless expires
    now = new Date * 1
    return unless now < expires
    value.val

  set: (key, value, options = {}) =>
    return unless key && value
    return if JSON.stringify(value) == JSON.stringify(@_get(key))
    value = @wrapValueWithExpiry(value)
    @CACHE[key] = value
    @trigger "change:#{key}", @unwrapValueWithExpiry(value)

    if options.saveToLocalStorage == true
      @_storeSet(key, value)

  _storeSet: (key, value) =>
    return unless window.store and store.enabled
    key = @_storeKey(key)
    store.set(key, value)

  _get: (key) =>
    value = @CACHE[key] or @_storeGet(key)
    @unwrapValueWithExpiry(value)

  get: (key) =>
    value = @_get(key)
    @trigger "receive:#{key}", value

  _storeGet: (key) =>
    return unless window.store and store.enabled
    key = @_storeKey(key)
    store.get(key)

  remove: (key) =>
    delete @CACHE[key]
    @_storeRemove(key)
    @trigger "remove:#{key}"

  _storeRemove: (key) =>
    return unless window.store and store.enabled
    key = @_storeKey(key)
    store.remove(key)

    @trigger "remove:#{key}"

  _storeKey: (key) -> "cache:#{key}"

new Cache
