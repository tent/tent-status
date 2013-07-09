Marbles.Views.ProfilePostCount = class PostCountView extends Marbles.Views.ProfileResourceCount
  @view_name: 'profile/post_count'
  @model: TentStatus.Models.StatusPost
  @resource_name: {singular: 'post', plural: 'posts'}
  @route: 'profile'

  context: =>
    _.extend super,
      url: TentStatus.Helpers.entityProfileUrl(@profile().get('entity'))
