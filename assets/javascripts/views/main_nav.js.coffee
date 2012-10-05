TentStatus.Views.main_nav = new class MainNavigationView extends Backbone.View
  initialize: ->
    @setElement document.getElementById('main-nav')

    @$components = {
      toggle: $('.btn-navbar[data-toggle=collapse]', @$el)
      collapse: $('.nav-collapse', @$el)
    }

    @visible = false

    @css = {
      visible:
        height: 'auto'
        overflow: 'visible'
      hidden:
        height: '0px'
        overflow: 'hidden'
    }

    @$components.toggle.on 'click', @toggle

  toggle: =>
    if @visible
      @hide()
    else
      @show()

  show: =>
    @visible = true
    @$components.collapse.css @css.visible

  hide: =>
    @visible = false
    @$components.collapse.css @css.hidden
