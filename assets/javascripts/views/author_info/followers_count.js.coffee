TentStatus.Views.AuthorInfoFollowersCount = class FollowersCountView extends TentStatus.Views.AuthorInfoResourceCount
  @view_name: 'author_info_followers_count'
  @model: TentStatus.Models.Follower
  @resource_name: {singular: 'follower', plural: 'followers'}
