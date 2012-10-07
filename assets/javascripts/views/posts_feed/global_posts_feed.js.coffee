class TentStatus.Views.GlobalPostsFeed extends TentStatus.Views.PostsFeed
  initialize: (options = {}) ->
    return unless TentStatus.config.tent_host_api_root
    options.api_root = TentStatus.config.tent_host_api_root
    super(options)

