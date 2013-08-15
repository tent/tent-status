Marbles.Views.AppNavigationItem = class AppNavigationItemView extends Marbles.View
  @view_name: 'app_navigation_item'

  @find: (fragment) ->
    for item in @allItems()
      return item if item.fragment == fragment
    null

  @allItems: ->
    for cid in Marbles.View.instances.app_navigation_item
      Marbles.View.instances.all[cid]

  @disableAllExcept: (whitelist...) ->
    for item in @allItems()
      continue if whitelist.indexOf(item.fragment) != -1
      item.disable()

  initialize: =>
    @fragment = Marbles.DOM.attr(@el, 'data-fragment')
    Marbles.DOM.on(@el, 'click', @navigate)

  navigate: (e) =>
    return unless @disabled
    e?.preventDefault()

  disable: =>
    @disabled = true
    Marbles.DOM.addClass(@el, 'disabled')

  enable: =>
    @disabled = false
    Marbles.DOM.removeClass(@el, 'disabled')

