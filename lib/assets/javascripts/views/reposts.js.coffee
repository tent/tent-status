Marbles.Views.Reposts = class RepostsView extends Marbles.View
  @template_name: 'reposts'
  @view_name: 'reposts'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    @entity = options.entity
    super

    @render()
