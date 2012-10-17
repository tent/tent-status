class TentStatus.ChildPostsPaginator
  onLastPage: false
  PER_PAGE: TentStatus.config.PER_PAGE
  existing_post_ids: []

  constructor: (@post, @child_posts) ->
    return unless @child_posts

    @child_posts.each (post) => @existing_post_ids.push(post.get 'id')

    @updatePaginationParams()

  updatePaginationParams: (posts = @child_posts) =>
    @params = {
      before_id: posts.last()?.get('id')
      before_id_entity: posts.last()?.get('entity')
    }

  nextPage: =>
    return if @onLastPage
    @post.fetchChildren @appendPosts, @params

  appendPosts: (posts) =>
    return unless posts

    for post in posts.toArray()
      if @existing_post_ids.indexOf(post.get('id')) != -1
        posts.remove(post)
      else
        @existing_post_ids.push(post.get 'id')
        @child_posts.push post

    unless posts.length
      @onLastPage = true
      return

    @onLastPage = posts.length < @PER_PAGE
    @updatePaginationParams(posts)

    @trigger 'fetch:success', posts

  toArray: => @child_posts.toArray()

_.extend TentStatus.ChildPostsPaginator::, Backbone.Events

