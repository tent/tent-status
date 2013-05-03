RegExp.escape ?= (text) ->
  text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
