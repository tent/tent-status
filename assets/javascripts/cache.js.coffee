class Cache extends TentStatus.Events
  CACHE: {}

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
    return if value == @unwrapValueWithExpiry(@CACHE[key])
    value = @wrapValueWithExpiry(value)
    @CACHE[key] = value
    @trigger "change:#{key}", value

    if options.saveToLocalStorage == true
      @_storeSet(key, value)

  _storeSet: (key, value) =>
    return unless window.store and store.enabled
    key = @_storeKey(key)
    store.set(key, value)

  get: (key) =>
    value = @CACHE[key] or @_storeGet(key)
    @unwrapValueWithExpiry(value)

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
    [event, key...] = key.split(':')
    key = key.join(':') if key.join
    callback?(@CACHE[key]) if event == 'change' && @CACHE[key]
    super

TentStatus.Cache = new Cache

