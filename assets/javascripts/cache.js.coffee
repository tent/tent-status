class Cache
  CACHE: {}

  set: (key, value) =>
    return unless key && value
    @CACHE[key] = value
    @trigger "change:#{key}", value

  get: (key) =>
    @CACHE[key]

  on: (key, callback) =>
    return callback?(@CACHE[key]) if @CACHE[key]
    super

_.extend Cache::, Backbone.Events
TentStatus.Cache = new Cache

