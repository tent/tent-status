class TentStatus.Views.DomainPostsFeed extends TentStatus.Views.PostsFeed
  initialize: (options = {}) ->
    options.api_root ?= TentStatus.config.current_tent_api_root
    options.posts_params = {
      entity: TentStatus.config.domain_entity.toStringWithoutSchemePort()
    }
    super(options)
