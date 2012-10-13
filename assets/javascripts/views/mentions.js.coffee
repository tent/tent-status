class TentStatus.Views.Mentions extends TentStatus.View
  templateName: 'mentions'

  initialize: (options = {}) ->
    return
    @container = TentStatus.Views.container
    @entity = options.entity

    super

    @on 'ready', =>
      @fetch_posts_pool_view = @child_views.FetchPostsPool?[0]
      if @fetch_posts_pool_view.pool
        @initFetchPostsPoolListener()
      else
        @fetch_posts_pool_view.once 'pool:init', @initFetchPostsPoolListener

    @render()

  context: =>
    domain_entity: @entity.toStringWithoutSchemePort()
    profileUrl: TentStatus.Helpers.entityProfileUrl @entity
    formatted:
      domain_entity: TentStatus.Helpers.formatUrl @entity.toStringWithoutSchemePort()

  initFetchPostsPoolListener: =>
    TentStatus.background_mentions_pool?.set 'mentions_count', 0
    @fetch_posts_pool_view.pool.on 'fetch:success', => @cacheFetchPostsPoolSinceId()

  cacheFetchPostsPoolSinceId: (since_id = @fetch_posts_pool_view.pool.sinceId, since_id_entity = @fetch_posts_pool_view.pool.since_id_entity) =>
    TentStatus.background_mentions_pool?.set 'since_id', since_id
    TentStatus.background_mentions_pool?.set 'since_id_entity', since_id_entity

