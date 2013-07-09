Marbles.Views.Subscribers = class SubscribersView extends Marbles.View
  @view_name: 'subscribers'
  @template_name: 'subscribers'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    @entity = options.entity
    super

    @render()

  context: =>
    entity: @entity

