class GlobalNavigationView extends Marbles.View
  @view_name: 'global_navigation'

  @buildMappingRegexp: (mapping) ->
    new RegExp("#{mapping.replace("*", ".*?")}")

  constructor: ->
    super

    @active_class = 'nav-selected'

    @buildActiveMapping()
    @markActiveItem()

    Marbles.history.on 'route', (router, name, args) =>
      @markActiveItem()

  buildActiveMapping: =>
    @active_mapping = []
    for el in Marbles.DOM.querySelectorAll('li', @el)
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

TentStatus.on 'ready', =>
  return unless el = document.getElementById('global-nav')
  view = new GlobalNavigationView el: el
  view.trigger('ready')

