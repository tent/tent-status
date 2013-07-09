Marbles.Views.Subscriptions = class SubscriptionsView extends Marbles.View
  @template_name: 'subscriptions'
  @view_name: 'subscriptions'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    @entity = options.entity
    super

    @render()

  context: =>
    entity: @entity

