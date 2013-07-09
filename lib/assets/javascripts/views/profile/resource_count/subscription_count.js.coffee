Marbles.Views.ProfileSubscriptionCount = class SubscriptionCountView extends Marbles.Views.ProfileResourceCount
  @view_name: 'profile/subscription_count'
  @model: TentStatus.Models.Following
  @resource_name: {singular: 'subscription', plural: 'subscriptions'}
  @route: 'subscriptions'
