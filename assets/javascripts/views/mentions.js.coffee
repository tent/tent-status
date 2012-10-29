class TentStatus.Views.Mentions extends TentStatus.View
  templateName: 'mentions'

  initialize: (options = {}) ->
    @container = TentStatus.Views.container
    @entity = options.entity

    super

    @on 'ready', =>
      @fetch_posts_pool_view = @child_views.FetchPostsPool?[0]

      if @fetch_posts_pool_view.pool
        @cacheFetchPostsPoolSinceId()
      else
        @fetch_posts_pool_view.once 'pool:init', @cacheFetchPostsPoolSinceId

      TentStatus.background_mentions_pool?.on 'change:mentions_count', =>
        @fetch_posts_pool_view.pool?.fetch()

    @render()

  context: =>
    domain_entity: @entity.toStringWithoutSchemePort()
    profileUrl: TentStatus.Helpers.entityProfileUrl @entity
    formatted:
      domain_entity: TentStatus.Helpers.formatUrl @entity.toStringWithoutSchemePort()

  cacheFetchPostsPoolSinceId: (since_id = @fetch_posts_pool_view.pool.sinceId, since_id_entity = @fetch_posts_pool_view.pool.since_id_entity) =>
    TentStatus.background_mentions_pool?.setCursor since_id_entity, since_id

