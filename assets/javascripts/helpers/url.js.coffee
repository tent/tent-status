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

  isEntityOnTentHostDomain: (entity) =>
    TentStatus.config.tent_host_domain && entity.match(new RegExp(TentStatus.config.tent_host_domain))

  ensureUrlHasScheme: (url) =>
    return unless url
    return url if url.match /^[a-z]+:\/\//i
    'http://' + url
