Marbles.Views.ProfileFollowingCount = class FollowingCountView extends Marbles.Views.ProfileResourceCount
  @view_name: 'profile/following_count'
  @model: TentStatus.Models.Following
  @resource_name: {singular: 'subscription', plural: 'subscriptions'}
  @path: '/subscriptions'
