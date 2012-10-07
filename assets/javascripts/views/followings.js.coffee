class TentStatus.Views.Followings extends TentStatus.View
  templateName: 'followings'

  initialize: (options = {}) ->
    @container = TentStatus.Views.container
    @entity = options.entity
    super
    @render()

  context: =>
    guest_authenticated: TentStatus.guest_authenticated || !TentStatus.config.domain_entity.assertEqual(@entity)
    profileUrl: TentStatus.Helpers.entityProfileUrl(@entity)
    domain_entity: @entity.toStringWithoutSchemePort()
    formatted:
      domain_entity: TentStatus.Helpers.formatUrl @entity.toStringWithoutSchemePort()

