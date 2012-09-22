class TentStatus.Views.DomainPostsFeed extends TentStatus.Views.PostsFeed
  initialize: (options = {}) ->
    options.api_root ?= TentStatus.config.current_tent_api_root
    super(options)
