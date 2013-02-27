Marbles.Views.LoadingIndicator = class LoadingIndicatorView extends TentStatus.View
  @view_name: 'loading_indicator'

  show: =>
    clearTimeout @_showTimeout
    @_showTimeout = setTimeout (=>
      Marbles.DOM.addClass(@el, 'pulse')

      clearTimeout @_pulseTimeout
      @_pulseTimeout = setTimeout @pulse, 1400
    ), 0

  pulse: =>
    @hide()
    @_pulseTimeout = setTimeout @show, 600

  hide: =>
    clearTimeout @_showTimeout
    clearTimeout @_pulseTimeout
    Marbles.DOM.removeClass(@el, 'pulse')

Marbles.Views.loading_indicator = new LoadingIndicatorView el: document.getElementById('loading-indicator')
