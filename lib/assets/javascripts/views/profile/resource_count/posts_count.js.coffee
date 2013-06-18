Marbles.Views.ProfilePostsCount = class PostsCountView extends Marbles.Views.ProfileResourceCount
  @view_name: 'profile/posts_count'
  @model: TentStatus.Models.StatusPost
  @resource_name: {singular: 'post', plural: 'posts'}
  @path: '/profile'

  context: =>
    _.extend super,
      url: TentStatus.Helpers.entityProfileUrl(@profile().get('entity'))
