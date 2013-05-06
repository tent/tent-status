Marbles.Views.MiniProfilePostsCount = class PostsCountView extends Marbles.Views.MiniProfileResourceCount
  @view_name: 'author_info_posts_count'
  @model: TentStatus.Models.StatusPost
  @resource_name: {singular: 'post', plural: 'posts'}

  context: =>
    _.extend super,
      url: TentStatus.Helpers.entityProfileUrl(@profile().get('entity'))
