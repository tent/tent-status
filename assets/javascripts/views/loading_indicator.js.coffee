TentStatus.Views.loading_indicator = new class LoadingIndicatorView extends Backbone.View
  initialize: ->
    @setElement document.getElementById('loading-indicator')

  show: =>
    clearInterval @_pulseInterval
    clearTimeout @_pulseTimeout
    @$el.addClass 'pulse'
    @_pulseInterval = setInterval =>
      @$el.addClass 'pulse'
      @_pulseTimeout = setTimeout =>
        @$el.removeClass('pulse')
      , 1000
    , 1200

  hide: =>
    clearInterval @_pulseInterval
    @$el.removeClass 'pulse'
