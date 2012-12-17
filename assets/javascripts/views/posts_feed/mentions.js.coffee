TentStatus.Views.MentionsPostsFeed = class MentionsPostsFeedView extends TentStatus.Views.PostsFeed
  @view_name: 'mentions_posts_feed'

  init: =>
    @on 'ready', @initPostViews
    @on 'ready', @initAutoPaginate

    @initPostsCollection()

    TentStatus.Models.Post.on 'create:success', (post, xhr) =>
      return unless post.entityMentioned(@parent_view.entity)
      @posts_collection.unshift(post)
      @prependRender([post])

  initPostsCollection: (options = {}) =>
    unless options.client
      return HTTP.TentClient.fetch {entity: @parent_view.entity}, (client) =>
        @initPostsCollection(_.extend(options, {client: client}))

    @posts_collection = new TentStatus.Collections.Posts
    @posts_collection.client = options.client
    @posts_collection.params = {
      mentioned_entity: @parent_view.entity
      post_types: TentStatus.config.post_types
      limit: TentStatus.config.PER_PAGE
    }
    @fetch()
