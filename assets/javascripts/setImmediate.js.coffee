# TODO: use window.postMessage
window.setImmediate ?= (->
  window.clearImmediate = window.clearTimeout

  (fn, args...) ->
    setTimeout(fn, 0, args...)
)()
