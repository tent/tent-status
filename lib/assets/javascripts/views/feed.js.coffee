Marbles.Views.Feed = class FeedView extends TentStatus.View
  @template_name: 'feed'
  @view_name: 'feed'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @render()
