class GlobalNavigationView extends Marbles.View
  @view_name: 'global_navigation'
  constructor: ->
    super

TentStatus.on 'ready', =>
  return unless el = document.getElementById('global-nav')
  view = new GlobalNavigationView el: el
  view.trigger('ready')

