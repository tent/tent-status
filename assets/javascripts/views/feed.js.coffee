TentStatus.Views.Feed = class FeedView extends TentStatus.View
  @template_name: 'feed'

  constructor: (options = {}) ->
    @container = TentStatus.Views.container
    super

    @render()
