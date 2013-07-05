Marbles.Views.NavigationActive = class NavigationActiveView extends Marbles.View
  @view_name: 'navigation_active'

  @buildMappingRegexp: (mapping) ->
    new RegExp("#{mapping.replace("*", ".*?")}")

  initialize: ->
    @active_class = Marbles.DOM.attr(@el, 'data-active-class')
    @active_selector = Marbles.DOM.attr(@el, 'data-active-selector')

    @buildActiveMapping()
    @markActiveItem()

    Marbles.history.on 'route', (router, name, args) =>
      @markActiveItem()

  buildActiveMapping: =>
    @active_mapping = []
    for el in Marbles.DOM.querySelectorAll(@active_selector, @el)
      continue unless mapping = Marbles.DOM.attr(el, 'data-match-url')
      reg = @constructor.buildMappingRegexp(mapping)
      @active_mapping.push([reg, el])
    @active_mapping = _.sortBy(@active_mapping, ( (item) => item[0].source.length * -1 ))

  markActiveItem: =>
    path = window.location.pathname
    matched = false
    for item in @active_mapping
      [reg, el] = item
      if !matched && reg.test(path)
        matched = true
        Marbles.DOM.addClass(el, @active_class)
      else
        Marbles.DOM.removeClass(el, @active_class)


