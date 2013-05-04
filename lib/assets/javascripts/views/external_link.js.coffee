Marbles.Views.ExternalLink = class ExternalLinkView extends Marbles.View
  @view_name: 'external_link'

  constructor: (options = {}) ->
    super

    Marbles.DOM.on @el, 'click', (e) =>
      middle_click = event.which == 2
      return true if middle_click || e.ctrlKey || e.metaKey || e.shiftKey

      e.preventDefault()
      url = Marbles.DOM.attr(@el, 'href')
      window.open(url) if url

