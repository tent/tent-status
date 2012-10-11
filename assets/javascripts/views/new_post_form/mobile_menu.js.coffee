TentStatus.Views.mobile_menu = new class MobileMenu extends Backbone.View
  initialize: ->
    @setElement document.getElementById('nav-right')
    @$toggle = $('#menu-toggle')

    @visible = false
    @hidden_class = 'mobile-hide'
    @hide_icon_class = 'ticon-menu_close'
    @show_icon_class = 'ticon-menu_open'

    @$icon = $(".#{@show_icon_class}", @$toggle)

    @$toggle.off('click.toggle').on 'click.toggle', @toggleMenu

  toggleMenu: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    @$el.addClass(@hidden_class)
    TentStatus.Views.container.$el.removeClass(@hidden_class)
    @$icon.removeClass(@hide_icon_class).addClass(@show_icon_class)
    window.scrollTo(window.scrollX, @scrollY)

  show: =>
    @visible = true
    @$el.removeClass(@hidden_class)
    @scrollY = window.scrollY
    TentStatus.Views.container.$el.addClass(@hidden_class)
    @$icon.removeClass(@show_icon_class).addClass(@hide_icon_class)

