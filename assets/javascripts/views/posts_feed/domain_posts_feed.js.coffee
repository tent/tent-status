class TentStatus.Views.DomainPostsFeed extends TentStatus.Views.PostsFeed
  initialize: (options = {}) ->
    entity = options.parentView.entity
    if TentStatus.config.domain_entity.assertEqual(entity)
      options.api_root ?= TentStatus.config.tent_api_root
      options.posts_params = {
        entity: TentStatus.config.domain_entity.toStringWithoutSchemePort()
      }
    else
      options.api_root ?= "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent entity.toStringWithoutSchemePort()}"
      options.posts_params = {
        entity: entity.toStringWithoutSchemePort()
      }
    super(options)
