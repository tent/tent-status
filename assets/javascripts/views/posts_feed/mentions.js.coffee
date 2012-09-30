class TentStatus.Views.MentionsPostFeed extends TentStatus.Views.PostsFeed
  initialize: (options = {}) ->
    options.api_root ?= TentStatus.config.tent_api_root
    options.posts_params = {
      mentioned_entity: TentStatus.config.domain_entity.toStringWithoutSchemePort()
    }
    super(options)
