class BackgroundMentionsPool
  sep: '__SEP__'
  constructor: ->
    return unless @entity = TentStatus.config.current_entity?.toStringWithoutSchemePort()
    @cache_key = {
      since_id: "#{@entity}#{@sep}mentions_since_id"
      since_id_entity: "#{@entity}#{@sep}mentions_since_id_entity"
    }
    return

    TentStatus.Cache.on "change:#{@cache_key.since_id}", (since_id) =>
      @set 'since_id', since_id

    TentStatus.Cache.on "change:#{@cache_key.since_id_entity}", (since_id_entity) =>
      @set 'since_id_entity', since_id_entity

    @on 'change:since_id', @initFetchInterval
    @on 'change:since_id_entity', @initFetchInterval

    [@since_id, @since_id_entity] = [TentStatus.Cache.get(@cache_key.since_id), TentStatus.Cache.get(@cache_key.since_id_entity)]
    if @since_id and @since_id_entity
      @initFetchInterval()
    else
      new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts", {
        mentioned_entity: @entity
        post_types: TentStatus.config.post_types
      }, (posts, xhr) =>
        return unless xhr.status == 200
        return unless posts?.length
        return unless post = posts[0]
        @set 'since_id', post.id
        @set 'since_id_entity', post.entity

  initFetchInterval: =>
    @fetch_interval?.clear()

    return unless @since_id && @since_id_entity

    @fetch_params = {
      since_id: @since_id
      since_id_entity: @since_id_entity
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
    cache_key = @cache_key[key]
    TentStatus.Cache.set(cache_key, val, {saveToLocalStorage:true}) if cache_key
    @trigger "change:#{key}", val
    val

_.extend BackgroundMentionsPool::, Backbone.Events

TentStatus.background_mentions_pool = new BackgroundMentionsPool
