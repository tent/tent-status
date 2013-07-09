Marbles.Views.Subscription = class SubscriptionView extends Marbles.View
  @view_name: 'subscription'
  @template_name: 'subscription'

  getEntity: =>
    @parentView()?.getEntity?()

