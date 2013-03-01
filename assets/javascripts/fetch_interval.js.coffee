class TentStatus.FetchInterval
  constructor: (options = {}) ->
    @options = _.extend {
      max_delay: TentStatus.config.MAX_FETCH_LATENCY
      delay_increment: TentStatus.config.FETCH_INTERVAL
    }, options

  start: => @reset()
  stop: => @clear()

  resetInterval: =>
    @clear()
    @_delay_interval = setInterval @options.fetch_callback, @delay_offset

  increaseDelay: =>
    @delay_offset = Math.min(@delay_offset + @options.delay_increment, @options.max_delay - @options.delay_increment)
    @resetInterval()

  reset: =>
    @delay_offset = @options.delay_increment
    @resetInterval()

  clear: =>
    clearInterval @_delay_interval

