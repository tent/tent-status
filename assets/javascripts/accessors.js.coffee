TentStatus.Accessors = {
  set: (k, v) ->
    old_v = @[k]
    @[k] = v
    @trigger("change:#{k}", v, old_v) unless v == old_v
    v

  get: (k) ->
    @[k]
}
