Marbles.Views.Mentions = class MentionsView extends TentStatus.View
  @template_name: 'mentions'
  @view_name: 'mentions'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    @entity = options.entity
    super

    @render()
