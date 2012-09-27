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
    else
      "/posts/#{encodeURIComponent entity}/#{post_id}"

  entityProfileUrl: (entity) ->
    return unless entity
    if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
      "#{entity}"
    else
      "/posts/#{encodeURIComponent entity}"

  isEntityOnTentHostDomain: (entity) ->
    TentStatus.config.tent_host_domain && entity.match(new RegExp(TentStatus.config.tent_host_domain))

  ensureUrlHasScheme: (url) ->
    return unless url
    return url if url.match /^[a-z]+:\/\//i
    'http://' + url

  substringIndices: (string, substring) ->
    return [] unless string and substring

    _indices = []
    _length = substring.length
    _offset = 0
    while string.length and (i = string.substr(_offset, string.length).indexOf(substring)) and i != -1
      _start_index = i + _offset
      _end_index = _start_index + _length
      _offset += i + _length
      _indices.push _start_index, _end_index

    _indices

  extractMentionsWithIndices: (text, options = {}) ->
    _mentions = []
    _entities = {}

    unless options.exclude_urls == true
      for i in TentStatus.Helpers.extractUrlsWithIndices(text)
        entity = i.url
        _is_carrot_mention = text.substr(i.indices[0]-1, 1) == '^'
        _is_tent_subdomain = entity.match(new RegExp(TentStatus.config.tent_host_domain))
        continue unless _is_carrot_mention or _is_tent_subdomain

        original_text = entity

        unless entity.match(/^https?:\/\//)
          scheme = 'https://'
          entity = scheme + entity

        _mentions.push {
          entity: entity
          url: entity
          text: original_text
          indices: i.indices
        }
        _entities[entity] = true

    if TentStatus.config.tent_host_domain
      m = text.match(
        new RegExp("[\\^]([a-z0-9]+(?:\.#{TentStatus.config.tent_host_domain})?)(?=[\\W]|\\$)")
      )
      if entity = m?[1]
        original_text = entity
        _length = original_text.length
        _indices = TentStatus.Helpers.substringIndices(text, original_text)
        if entity.match(new RegExp(TentStatus.config.tent_host_domain))
          entity = "https://#{entity}"
        else
          entity = "https://#{entity}.#{TentStatus.config.tent_host_domain}"

        _mentions.push {
          entity: entity
          text: original_text
          url: entity
          indices: _indices
        }
        _entities[entity] = true

    _mentions

