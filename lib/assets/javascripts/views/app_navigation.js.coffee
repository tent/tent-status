Marbles.Views.AppNavigation = class AppNavigationView extends Marbles.View
  @view_name: 'app_navigation'

  elements: {}

  constructor: (options = {}) ->
    @setupMenuToggle()

  setupMenuToggle: =>
    @elements.menu_toggle = Marbles.DOM.querySelector('.js-menu-switch')
    @elements.app_nav_list = Marbles.DOM.querySelector('.app-nav-list')

    @menu_visible = Marbles.DOM.match(@elements.app_nav_list, '.show')

    Marbles.DOM.on @elements.menu_toggle, 'click', @toggleMenu

  toggleMenu: (e) =>
    e?.preventDefault()

    if @menu_visible
      @hideMenu()
    else
      @showMenu()

  showMenu: =>
    Marbles.DOM.addClass @elements.app_nav_list, 'show'
    @menu_visible = true

  hideMenu: =>
    Marbles.DOM.removeClass @elements.app_nav_list, 'show'
    @menu_visible = false

