TentStatus.Views.AuthorInfoPostsCount = class PostsCountView extends TentStatus.Views.AuthorInfoResourceCount
  @view_name: 'author_info_posts_count'
  @model: TentStatus.Models.Post
  @resource_name: {singular: 'post', plural: 'posts'}

  context: =>
    _.extend super,
      url: TentStatus.Helpers.entityProfileUrl(@profile().get('entity'))
