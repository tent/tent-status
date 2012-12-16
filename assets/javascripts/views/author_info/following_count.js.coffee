TentStatus.Views.AuthorInfoFollowingCount = class FollowingCountView extends TentStatus.Views.AuthorInfoResourceCount
  @view_name: 'author_info_following_count'
  @model: TentStatus.Models.Following
  @resource_name: {singular: 'following', plural: 'following'}
