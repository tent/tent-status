Marbles.Views.ProfileSubscriberCount = class SubscriberCountView extends Marbles.Views.ProfileResourceCount
  @view_name: 'profile/subscriber_count'
  @model: TentStatus.Models.Follower
  @resource_name: {singular: 'subscriber', plural: 'subscribers'}
  @route: 'subscribers'
