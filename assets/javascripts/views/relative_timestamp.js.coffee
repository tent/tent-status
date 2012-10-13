class TentStatus.Views.RelativeTimestamp extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @datetime = moment.unix(parseInt @$el.attr('data-datetime'))
    @update()

  update: =>
    clearTimeout @_updateTimestampTimeout
    return unless _.last(@$el.parents()) == document.body.parentNode
    now = moment()
    if now.diff(@datetime, 'days') > 0
      return @$el.val TentStatus.Helpers.formatTime @datetime.unix()
    else if now.diff(@datetime, 'hours') > 0
      @_updateTimestampTimeout = setTimeout @update, 3600000
    else if now.diff(@datetime, 'minutes') > 0
      @_updateTimestampTimeout = setTimeout @update, 60000
    else
      @_updateTimestampTimeout = setTimeout @update, 15000

    @$el.text @datetime.fromNow()

