class TentStatus.Views.Mentions extends TentStatus.View
  templateName: 'mentions'

  initialize: ->
    @container = TentStatus.Views.container

    super

    @render()

  context: =>
    domain_entity: TentStatus.config.domain_entity.toStringWithoutSchemePort()
    formatted:
      domain_entity: TentStatus.Helpers.formatUrl TentStatus.config.domain_entity.toStringWithoutSchemePort()
