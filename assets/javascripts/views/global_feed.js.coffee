class TentStatus.Views.GlobalFeed extends TentStatus.View
  templateName: 'global_feed'

  initialize: ->
    @container = TentStatus.Views.container
    super
    @render()

