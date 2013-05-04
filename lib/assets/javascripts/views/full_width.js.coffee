Marbles.Views.FullWidth = class FullWidthView extends Marbles.View
  @view_name: 'full_width'

  constructor: ->
    super

    @calibrate()
    TentStatus.on 'window:resize', @calibrate

  calibrate: =>
    width = parseInt(Marbles.DOM.getStyle(@el.parentNode, 'width'))
    padding = parseInt(Marbles.DOM.getStyle(@el, 'padding-left')) + parseInt(Marbles.DOM.getStyle(@el, 'padding-right'))
    border = parseInt(Marbles.DOM.getStyle(@el, 'border-left-width')) + parseInt(Marbles.DOM.getStyle(@el, 'border-right-width'))
    Marbles.DOM.setStyle(@el, 'width', "#{width - padding - border}px")

