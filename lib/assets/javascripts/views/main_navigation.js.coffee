class MainNavigationView extends Marbles.View
  @view_name: 'main_navigation'
  constructor: ->
    super

TentStatus.on 'ready', =>
  view = new MainNavigationView el: document.getElementById('main-nav')
  view.trigger('ready')

