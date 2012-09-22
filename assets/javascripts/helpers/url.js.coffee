_.extend TentStatus.Helpers,
  postUrl: (post) ->
    return unless post and post.get
    entity = post.get('entity')

    if entity.match /\.tent\.is/
      "#{entity}/posts/#{post.get 'id'}"
    else
      "/posts/#{encodeURIComponent entity}/#{post.get('id')}"

  entityProfileUrl: (entity) ->
    return unless entity
    if entity.match /\.tent\.is/
      "#{entity}"
    else
      "/posts/#{encodeURIComponent entity}"
