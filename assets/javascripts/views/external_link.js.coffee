class TentStatus.Views.ExternalLink extends Backbone.View
  initialize: (options = {}) ->
    @$el.off('click.external').on 'click.external', (e) =>
      e.preventDefault()
      window.open(@$el.attr('href'))
      false
