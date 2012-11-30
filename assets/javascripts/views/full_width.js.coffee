TentStatus.Views.FullWidth = class FullWidthWidth extends TentStatus.View
  @view_name: 'full_width'

  constructor: ->
    super

    @calibrate()
    TentStatus.on 'window:resize', @calibrate

  calibrate: =>
    width = parseInt(DOM.getStyle(@el.parentNode, 'width'))
    padding = parseInt(DOM.getStyle(@el, 'padding-left')) + parseInt(DOM.getStyle(@el, 'padding-right'))
    border = parseInt(DOM.getStyle(@el, 'border-left-width')) + parseInt(DOM.getStyle(@el, 'border-right-width'))
    DOM.setStyle(@el, 'width', "#{width - padding - border}px")

