Marbles.Views.SiteFeed = class SiteFeedView extends Marbles.View
  @template_name: 'site_feed'
  @view_name: 'site_feed'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @render()
