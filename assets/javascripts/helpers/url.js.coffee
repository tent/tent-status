_.extend TentStatus.Helpers,
  postUrl: (post) ->
    return unless post and post.get
    entity = post.get('entity')

    if (new HTTP.URI entity).hostname == TentStatus.config.domain_entity.hostname
      "/posts/#{post.get('id')}"
    else if entity.match /\.tent\.is/
      "#{entity}/posts/#{post.get 'id'}"
    else
      "/posts/#{encodeURIComponent entity}/#{post.get('id')}"

  entityPostUrl: (entity, post_id) ->
    return unless entity and post_id
    if entity.match /\/.tent\.is/
      "#{entity}/posts/#{post_id}"
    else
      "/posts/#{encodeURIComponent entity}/#{post_id}"

  entityProfileUrl: (entity) ->
    return unless entity
    if entity.match /\.tent\.is/
      "#{entity}"
    else
      "/posts/#{encodeURIComponent entity}"
