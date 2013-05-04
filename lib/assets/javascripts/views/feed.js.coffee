Marbles.Views.Feed = class FeedView extends Marbles.View
  @template_name: 'feed'
  @view_name: 'feed'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @render()
