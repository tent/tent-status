class TentStatus.Views.Followings extends TentStatus.View
  templateName: 'followings'

  initialize: ->
    @container = TentStatus.Views.container
    super
    @render()

  context: =>
    {}

