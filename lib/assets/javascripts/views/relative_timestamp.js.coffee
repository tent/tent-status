Marbles.Views.RelativeTimestamp = class RelativeTimestampView extends Marbles.View
  @view_name: 'relative_timestamp'

  constructor: ->
    super

    @time = parseInt Marbles.DOM.attr(@el, 'data-datetime')

    @on 'ready', @setUpdateDelay
    @setUpdateDelay()

  setUpdateDelay: =>
    delta = (new Date * 1) - (@time * 1000)

    if delta < 60000 # less than 1 minute ago
      setTimeout @render, 2000 # update in 2 seconds
    else if delta < 3600000 # less than 1 hour ago
      setTimeout @render, 30000 # update in 30 seconds
    else if delta < 86400000 # less than 1 day ago
      setTimeout @render, 1800000 # update in 30 minutes
    else if delta < 2678400000 # 31 days ago
      setTimeout @render, 43200000 # update in 12 hours
    else
      setTimeout @render, 2419200 # update in 28 days

  context: =>
    formatted:
      time: TentStatus.Helpers.formatRelativeTime @time

  renderHTML: (context = @context()) =>
    context.formatted.time.toString()

