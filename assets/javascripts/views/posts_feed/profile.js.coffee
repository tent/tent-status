TentStatus.Views.ProfilePostsFeed = class ProfilePostsFeedView extends TentStatus.Views.PostsFeed
  @view_name: 'profile_posts_feed'

  init: =>
    @on 'ready', @initPostViews
    @on 'ready', @initAutoPaginate

    @initPostsCollection()

    TentStatus.Models.Post.on 'create:success', (post, xhr) =>
      return unless post.get('entity') == @profile().get('entity')
      @posts_collection.unshift(post)
      @prependRender([post])

  initPostsCollection: (options = {}) =>
    profile = options.profile || @profile()
    unless options.client
      return HTTP.TentClient.fetch {entity: profile.get('entity')}, (client) =>
        @initPostsCollection(_.extend(options, {client: client}))

    @posts_collection = new TentStatus.Collections.Posts
    @posts_collection.client = options.client
    @posts_collection.params = {
      post_types: TentStatus.config.post_types
      entity: profile.get('entity')
      limit: TentStatus.config.PER_PAGE
    }
    @fetch()

  profile: => @parent_view.profile()
