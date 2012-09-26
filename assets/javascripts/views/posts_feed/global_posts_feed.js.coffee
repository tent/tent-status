class TentStatus.Views.GlobalPostsFeed extends TentStatus.Views.PostsFeed
  initialize: (options = {}) ->
    options.api_root = "/api"
    super(options)

