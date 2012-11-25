_.extend TentStatus.Helpers,
  isCurrentUserEntity: (entity) ->
    return false unless TentStatus.config.current_entity
    TentStatus.config.current_entity.assertEqual( new HTTP.URI entity )

  isDomainEntity: (entity) ->
    return false unless TentStatus.config.domain_entity
    TentStatus.config.domain_entity.assertEqual( new HTTP.URI entity )
