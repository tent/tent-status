TentStatus.Views.SiteFeed = class SiteFeedView extends TentStatus.View
  @template_name: 'site_feed'
  @view_name: 'site_feed'

  constructor: (options = {}) ->
    @container = TentStatus.Views.container
    super

    @render()
