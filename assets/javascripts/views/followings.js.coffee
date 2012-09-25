class TentStatus.Views.Followings extends TentStatus.View
  templateName: 'followings'

  initialize: ->
    @container = TentStatus.Views.container
    super
    @render()

  context: =>
    guest_authenticated: !!TentStatus.guest_authenticated
    domain_entity: TentStatus.config.domain_entity.toStringWithoutSchemePort()
    formatted:
      domain_entity: TentStatus.Helpers.formatUrl TentStatus.config.domain_entity.toStringWithoutSchemePort()

