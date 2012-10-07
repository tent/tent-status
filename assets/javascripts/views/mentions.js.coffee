class TentStatus.Views.Mentions extends TentStatus.View
  templateName: 'mentions'

  initialize: (options = {}) ->
    @container = TentStatus.Views.container
    @entity = options.entity

    super

    @render()

  context: =>
    domain_entity: @entity.toStringWithoutSchemePort()
    profileUrl: TentStatus.Helpers.entityProfileUrl @entity
    formatted:
      domain_entity: TentStatus.Helpers.formatUrl @entity.toStringWithoutSchemePort()
