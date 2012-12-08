TentStatus.Accessors = {
  set: (keypath, v) ->
    return unless keypath && keypath.length
    keys = keypath.split('.')
    last_key = keys.pop()

    obj = @
    for k in keys
      obj[k] ?= {}
      obj = obj[k]

    old_v = obj[last_key]
    obj[last_key] = v
    @trigger("change:#{keypath}", v, old_v) unless v == old_v
    v

  get: (keypath) ->
    return unless keypath && keypath.length
    keys = keypath.split('.')
    last_key = keys.pop()

    obj = @
    for k in keys
      obj = obj[k]
      return unless obj

    obj[last_key]
}
