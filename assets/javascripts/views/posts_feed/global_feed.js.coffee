class TentStatus.Views.GlobalFeed extends TentStatus.Views.PostsFeed
  templateName: 'global_feed'

  initialize: (options = {}) ->
    options.api_root = "/api"
    super(options)

