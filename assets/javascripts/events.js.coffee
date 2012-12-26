@TentStatus ?= {}

##################################
# Inspired by Backbone.js Events #
##################################

event_splitter = /\s+/

TentStatus.Events = {
  on: (events, callback, context) ->
    events = events.split(event_splitter)
    @_events ?= {}
    for name in events
      do (name) =>
        @_events[name] ?= []
        @_events[name].push(callback: callback, context: context || @)

    # remove binding when listener anounces self-deletion
    context?.on? 'detach', (obj) =>
      @off(events, null, context)

    @ # chainable

  once: (events, callback, context) ->
    events = events.split(event_splitter)

    for name in events
      do (name) =>
        once = =>
          @off(name, once)
          callback.apply(context || @, arguments)
        @on(name, once, context)

    @ # chainable

  off: (events, callback, context) ->
    events = events?.split(event_splitter)

    if !events
      return @_events = {}

    for name in events
      if !callback && !context
        delete @_events[name]
        return

      return unless bindings = @_events[name]

      @_events[name] = _.reject bindings, (binding) =>
        return false if context && context != binding.context
        return false if callback && callback != binding.callback
        true

    @ # chainable

  trigger: (events, args...) ->
    events = events?.split(event_splitter)

    for name in events
      continue unless bindings = @_events?[name]
      for binding in bindings
        binding.callback?.apply?(binding.context, args)

    @ # chainable
}
