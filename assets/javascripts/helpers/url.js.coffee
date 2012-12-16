_.extend TentStatus.Helpers,
  postUrl: (post) ->
    return unless post and post.get
    entity = post.get('entity')

    if (new HTTP.URI entity).hostname == TentStatus.config.domain_entity.hostname
      "/posts/#{post.get('id')}"
    else if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
      "#{entity}/posts/#{post.get 'id'}"
    else
      "/posts/#{encodeURIComponent entity}/#{post.get('id')}"

  entityPostUrl: (entity, post_id) ->
    return unless entity and post_id
    if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
      "#{entity}/posts/#{post_id}"
    else if TentStatus.config.current_entity && TentStatus.Helpers.isEntityOnTentHostDomain(TentStatus.config.current_entity)
      "#{TentStatus.config.current_entity.toStringWithoutSchemePort()}/posts/#{encodeURIComponent entity}/#{post_id}"
    else
      "/posts/#{encodeURIComponent entity}/#{post_id}"

  entityProfileUrl: (entity) ->
    return unless entity
    if TentStatus.Helpers.isDomainEntity(entity)
      "/profile"
    else if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
      entity
    else if TentStatus.Helpers.isEntityOnTentHostDomain(TentStatus.config.current_entity)
      "#{TentStatus.config.current_entity.toStringWithoutSchemePort()}/#{encodeURIComponent entity}/profile"
    else
      "/#{encodeURIComponent entity}/profile"

  entityResourceUrl: (entity, path) ->
    return unless entity && path
    if TentStatus.Helpers.isDomainEntity(entity)
      path.replace(/^\/?/, '/')
    else
      "/#{encodeURIComponent entity}/#{path.replace(/^\//, '')}"

  currentHostWithoutSubdomain: ->
    window.location.hostname.replace(/^.*?([^.]*\.[^.]+)$/, '$1')

  isCurrentEntity: (entity) ->
    TentStatus.config.current_entity?.assertEqual(entity)

  isDomainEntity: (entity) ->
    TentStatus.config.domain_entity?.assertEqual(entity)

  isEntityOnTentHostDomain: (entity) ->
    TentStatus.config.tent_host_domain && entity.toString().match(
      new RegExp(TentStatus.Helpers.escapeRegExChars(TentStatus.config.tent_host_domain))
    )

  isURLExternal: (url) ->
    !url.match(
      new RegExp(TentStatus.Helpers.escapeRegExChars(
        TentStatus.Helpers.currentHostWithoutSubdomain()
      ))
    )

  ensureUrlHasScheme: (url) ->
    return unless url
    return url if url.match /^[a-z]+:\/\//i
    'http://' + url

  substringIndices: (string, substring, invalid_after) ->
    return [] unless string and substring

    _indices = []
    _length = substring.length
    _offset = 0
    while string.length
      i = string.substr(_offset, string.length).indexOf(substring)
      break if i == -1
      _start_index = i + _offset
      _end_index = _start_index + _length
      break if string.substr(_end_index, 1).match(invalid_after) if invalid_after
      _offset += i + _length
      _indices.push _start_index, _end_index

    _indices

  escapeRegExChars: (string) ->
    string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

  extractMentionsWithIndices: (text, options = {}) ->
    _mentions = []
    _entities = {}

    _from_urls = []
    unless options.exclude_urls == true
      for i in TentStatus.Helpers.extractUrlsWithIndices(text)
        entity = i.url
        _is_carrot_mention = text.substr(i.indices[0]-1, 1) == '^'
        _is_tent_subdomain = entity.match(new RegExp("\\w+\.#{TentStatus.Helpers.escapeRegExChars(TentStatus.config.tent_host_domain)}/?\\$"))
        continue unless _is_carrot_mention or _is_tent_subdomain

        original_text = entity

        unless entity.match(/^https?:\/\//)
          scheme = 'https://'
          entity = scheme + entity

        _from_urls.push {
          entity: entity
          url: entity.replace(/\/$/, '')
          text: original_text
          indices: i.indices
        } unless (_entities[entity] and options.uniq != false)
        _entities[entity] = true

    _from_mentions = []
    if TentStatus.config.tent_host_domain
      _regex = new RegExp("([\\^]([a-z0-9]{2,}(?:\.#{TentStatus.Helpers.escapeRegExChars(TentStatus.config.tent_host_domain)})?))(?!:\/\/)(?=[\\W]|$)", "i")
      _offset = 0
      _text = text
      while (_text = text.substr(_offset, text.length)) && _text.length && _regex.exec(_text)
        matched = RegExp.$1
        entity = RegExp.$2
        continue unless entity

        _offset += _text.indexOf(matched) + matched.length
        original_text = entity
        _length = original_text.length
        _indices = TentStatus.Helpers.substringIndices(text, matched, /[a-z0-9]/i)
        if entity.match(new RegExp(TentStatus.config.tent_host_domain))
          entity = "https://#{entity}"
        else
          entity = "https://#{entity}.#{TentStatus.config.tent_host_domain}"

        should_skip = false

        indexRangesForIndices = (indices) ->
          _ranges = []
          for start_index, index in indices
            continue if index % 2
            end_index = indices[index+1]
            _ranges.push [start_index..end_index]
          _ranges

        _index_ranges = indexRangesForIndices(_indices)

        doIndexRangesOverlap = (ranges_a, ranges_b) ->
          for r_a in ranges_a
            for r_b in ranges_b
              return true if _.intersection(r_a, r_b).length
          false

        for i in _from_urls
          i_index_ranges = indexRangesForIndices(i.indices)
          if doIndexRangesOverlap(_index_ranges, i_index_ranges)
            should_skip = true
            break

        continue if should_skip

        _from_mentions.push {
          entity: entity.toLowerCase()
          text: original_text
          url: entity.toLowerCase()
          indices: _indices
        } unless (_entities[entity] and options.uniq != false)
        _entities[entity] = true

    _mentions = _from_urls.concat(_from_mentions)
    _mentions

