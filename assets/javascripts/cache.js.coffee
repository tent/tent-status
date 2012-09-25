class Cache extends TentStatus.Events
  CACHE: {}

  set: (key, value, options = {}) =>
    return unless key && value
    @CACHE[key] = value
    @trigger "change:#{key}", value

    if options.saveToLocalStorage == true
      @_storeSet(key, value)

  _storeSet: (key, value) =>
    return unless window.store and store.enabled
    key = @_storeKey(key)
    store.set(key, value)

  get: (key) =>
    @CACHE[key] or @_storeGet(key)

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

  _storeKey: (key) -> "cache:#{key}"

  on: (key, callback) =>
    callback?(@CACHE[key]) if @CACHE[key]
    super

TentStatus.Cache = new Cache

