Marbles.Views.Replies = class RepliesView extends Marbles.View
  @template_name: 'replies'
  @view_name: 'replies'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    @entity = options.entity
    super

    @render()
