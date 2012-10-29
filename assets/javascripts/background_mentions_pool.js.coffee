class BackgroundMentionsPool
  constructor: ->
    return unless @entity = TentStatus.config.current_entity?.toStringWithoutSchemePort()

    TentStatus.on 'ready', @init

  init: =>
    TentStatus.Cursors.on "change:mentions", (cursor) =>
      @set 'cursor', cursor

    @on 'change:cursor', @initFetchInterval

    if TentStatus.isMentionsPage()
      @set 'mentions_count', 0
      return

    TentStatus.Cursors.get "mentions", (cursor) =>
      if cursor and cursor.post_entity and cursor.post_id
        @set 'cursor', cursor
      else
        new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts", {
          mentioned_entity: @entity
          post_types: TentStatus.config.post_types
        }, (posts, xhr) =>
          return unless xhr.status == 200
          return unless posts?.length
          return unless post = posts[0]
          TentStatus.Cursors.set "mentions", post.entity, post.id

  initFetchInterval: =>
    @fetch_interval?.clear()

    return unless @cursor and @cursor.post_entity and @cursor.post_id

    @fetch_params = {
      since_id: @cursor.post_id
      since_id_entity: @cursor.post_entity
      mentioned_entity: @entity
      post_types: TentStatus.config.post_types
    }

    @mentions_count = 0

    @fetch_interval = new TentStatus.FetchInterval {
      fetch_callback: @fetch
    }
    @fetch()

  fetch: =>
    return if @_fetch_in_progress
    @_fetch_in_progress = true
    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/count", @fetch_params, (count, xhr) =>
      @_fetch_in_progress = false
      return unless xhr.status == 200 && count != null
      last_mentions_count = @mentions_count
      @set 'mentions_count', count
      if last_mentions_count == @mentions_count
        @fetch_interval.increaseDelay()
      else
        @fetch_interval.reset()

  get: (key) => @[key]

  set: (key, val) =>
    @[key] = val
    @trigger "change:#{key}", val
    val

  setCursor: (post_entity, post_id) =>
    TentStatus.Cursors.set "mentions", post_entity, post_id

_.extend BackgroundMentionsPool::, Backbone.Events

TentStatus.background_mentions_pool = new BackgroundMentionsPool
