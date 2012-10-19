TentStatus.Views.user_menu = new class UserMenuView extends Backbone.View
  initialize: ->
    @setElement document.getElementById('user-menu')
    TentStatus.on 'profile:fetch:success', @init

    @$avatar = $('img.avatar', @$el)

    @show_class = 'active'

    @visible = false

    @$el.off().on 'touchstart', =>
      [@scrollX, @scrollY] = [window.scrollX, window.scrollY]
      @block_click = true
    @$el.on 'touchend', @toggle
    @$el.on 'click', (e) =>
      return false if @block_click
      return true if e.target.tagName == 'A'
      return unless url = @$el.attr('href')
      window.location.href = url

    $('body').off('touchstart.hide-menu').on 'touchstart.hide-menu', (e) =>
      @block_click = true
      [@scrollX, @scrollY] = [window.scrollX, window.scrollY]

    $('body').off('touchend.hide-menu').on 'touchend.hide-menu', (e) =>
      unless e.target == @el || (_.find $(e.target).parents(), (el) => el == @el)
        if @scrollX == window.scrollX && @scrollY == window.scrollY && @visible
          e.preventDefault()
          @hide()

  init: =>
    @profile = TentStatus.Models.profile
    @$avatar.attr 'src', @profile.avatar()

  toggle: (e) =>
    return unless @scrollX == window.scrollX && @scrollY == window.scrollY
    if @visible
      @hide()

      if e?.target.tagName.toLowerCase() == 'a'
        url = e.target.attributes.getNamedItem('href')?.value
        if url
          window.location.href = url
    else
      @show()

  show: =>
    @visible = true
    @$el.addClass(@show_class)

  hide: =>
    @visible = false
    @$el.removeClass(@show_class)

