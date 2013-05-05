_.extend TentStatus.Helpers,
  isCurrentUserEntity: (entity) ->
    return false unless TentStatus.config.current_user
    uri = new Marbles.HTTP.URI(TentStatus.config.current_user.entity)
    uri.assertEqual( new Marbles.HTTP.URI entity )

  isDomainEntity: (entity) ->
    return false unless TentStatus.config.domain_entity
    uri = new Marbles.HTTP.URI(TentStatus.config.domain_entity)
    uri.assertEqual( new Marbles.HTTP.URI entity )
