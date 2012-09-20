class TentStatus.Views.ExpandingTextArea extends Backbone.View
  initialize: ->
    @$el.on 'keyup', @adjustSize

    @initialHeight = @$el.height()

  adjustSize: (shouldExecute = false) =>
    @_padding ||= (parseInt(@$el.css 'padding-top') || 0) + (parseInt(@$el.css 'padding-bottom') || 0)
    scrollY = window.scrollY
    scrollX = window.scrollX
    @$el.height(0)
    @$el.css('height', "#{ Math.max(@el.scrollHeight - @_padding, @initialHeight) }px")
    window.scrollTo scrollX, scrollY

