Marbles.Views.Following = class FollowingView extends Marbles.View
  @template_name: 'following'
  @view_name: 'following'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @render()

