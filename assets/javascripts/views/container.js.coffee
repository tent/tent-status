TentStatus.Views.container = new class ContainerView extends Backbone.View
  initialize: ->
    @setElement document.getElementById('main')

  render: (html) =>
    @$el.html(html)
