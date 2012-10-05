class TentStatus.Views.GlobalPostsFeed extends TentStatus.Views.PostsFeed
  initialize: (options = {}) ->
    options.api_root = TentStatus.config.tent_host_api_root
    super(options)

