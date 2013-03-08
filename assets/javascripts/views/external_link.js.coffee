Marbles.Views.ExternalLink = class ExternalLinkView extends TentStatus.View
  @view_name: 'external_link'

  constructor: (options = {}) ->
    super

    Marbles.DOM.on @el, 'click', (e) =>
      e.preventDefault()
      url = Marbles.DOM.attr(@el, 'href')
      window.open(url) if url

