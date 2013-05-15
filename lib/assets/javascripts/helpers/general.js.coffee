_.extend TentStatus.Helpers,
  isCurrentUserEntity: (entity) ->
    return false unless TentStatus.config.current_user
    uri = new Marbles.HTTP.URI(TentStatus.config.current_user.entity)
    uri.assertEqual( new Marbles.HTTP.URI entity )

  isDomainEntity: (entity) ->
    return false unless TentStatus.config.domain_entity
    uri = new Marbles.HTTP.URI(TentStatus.config.domain_entity)
    uri.assertEqual( new Marbles.HTTP.URI entity )

  byteLength: (str) ->
    return unless typeof str is 'string'

    # https://gist.github.com/mathiasbynens/1010324
    index = 0
    bytes = 0
    while char_code = str.charCodeAt(index++)
      bytes += if char_code >> 11
        3
      else if char_code >> 7
        2
      else
        1

    bytes

