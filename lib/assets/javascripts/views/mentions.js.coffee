Marbles.Views.Mentions = class MentionsView extends Marbles.View
  @template_name: 'mentions'
  @view_name: 'mentions'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    @entity = options.entity
    super

    @render()
