TentStatus.Views.Mentions = class MentionsView extends TentStatus.View
  @template_name: 'mentions'
  @view_name: 'mentions'

  constructor: (options = {}) ->
    @container = TentStatus.Views.container
    @entity = options.entity
    super

    @render()
