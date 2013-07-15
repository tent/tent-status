_.extend TentStatus.Helpers,
  isCurrentUserEntity: (entity) ->
    return false unless TentStatus.config.meta
    uri = new Marbles.HTTP.URI(TentStatus.config.meta.entity)
    uri.assertEqual( new Marbles.HTTP.URI entity )

  isDomainEntity: (entity) ->
    return false unless TentStatus.config.domain_entity
    uri = new Marbles.HTTP.URI(TentStatus.config.domain_entity)
    uri.assertEqual( new Marbles.HTTP.URI entity )

  # Taken from http://mths.be/punycode
  decodeUCS: (string) ->
    chars = []
    counter = 0
    length = string.length

    while counter < length
      value = string.charCodeAt(counter++)
      if value >= 0xD800 && value <= 0xDBFF && counter < length
        # high surrogate, and there is a next character
        extra = string.charCodeAt(counter++)
        if (extra & 0xFC00) == 0xDC00 # low surrogate
          chars.push(((value & 0x3FF) << 10) + (extra & 0x3FF) + 0x10000)
        else
          # unmatched surrogate; only append this code unit, in case the next
          # code unit is the high surrogate of a surrogate pair
          chars.push(value)
          counter--
      else
        chars.push(value)

    chars

  numChars: (string) ->
    return 0 unless string
    @decodeUCS(string).length
