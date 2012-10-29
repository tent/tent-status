class TentStatus.Views.MentionsPostFeed extends TentStatus.Views.PostsFeed
  viewName: 'mentions_post_feed'

  initialize: (options = {}) ->
    @entity = options.parentView.entity
    if TentStatus.config.domain_entity.assertEqual(@entity)
      api_root = TentStatus.config.domain_tent_api_root
    else
      api_root = TentStatus.config.tent_proxy_root + "/#{encodeURIComponent @entity.toStringWithoutSchemePort()}"

    options.api_root ?= api_root
    options.posts_params = {
      mentioned_entity: @entity.toStringWithoutSchemePort()
    }

    @on 'pool:emptied', =>
      TentStatus.background_mentions_pool?.set 'mentions_count', 0
      options.parentView.cacheFetchPostsPoolSinceId(@posts.first().get('id'), @posts.first().get('entity'))

    super(options)

