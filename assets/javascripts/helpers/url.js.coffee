_.extend TentStatus.Helpers,
  postUrl: (post) ->
    return unless post and post.get
    entity = post.get('entity')

    if (new Marbles.HTTP.URI entity).hostname == TentStatus.config.domain_entity.hostname
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
    return unless entity
    TentStatus.config.tent_host_domain && entity.toString().match(
      new RegExp(TentStatus.Helpers.escapeRegExChars(TentStatus.config.tent_host_domain))
    )

  isAppSubdomain: =>
    TentStatus.config.tent_host_domain and window.location.hostname == "app.#{TentStatus.config.tent_host_domain.replace(/:\d+$/, '')}"

  isURLExternal: (url) ->
    !url.match(/^\//) && !url.match(
      new RegExp("^[a-z]+:\/\/#{TentStatus.Helpers.escapeRegExChars(
        TentStatus.Helpers.currentHostWithoutSubdomain()
      )}")
    )

  ensureUrlHasScheme: (url) ->
    return unless url
    return url if url.match /^[a-z]+:\/\//i
    return url if url.match /^\// # relative
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
    string ?= ""
    string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

