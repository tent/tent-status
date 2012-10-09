class BackgroundMentionsPool
  sep: '__SEP__'
  constructor: ->
    @entity = TentStatus.config.current_entity.toStringWithoutSchemePort()
    @cache_key = {
      since_id: "#{@entity}#{@sep}mentions_since_id"
      since_id_entity: "#{@entity}#{@sep}mentions_since_id_entity"
    }
    @since_id = TentStatus.Cache.get @cache_key.since_id
    @since_id_entity = TentStatus.Cache.get @cache_key.since_id_entity

    @fetch_params = {
      sinceId: @since_id
      since_id_entity: @since_id_entity
      mentioned_entity: @entity
      post_types: TentStatus.config.post_types
    }

    @mentions_count = 0

    @on 'change:since_id', (since_id) => TentStatus.Cache.set @cache_key.since_id, since_id, { saveToLocalStorage: true }
    @on 'change:since_id_entity', (since_id_entity) => TentStatus.Cache.set @cache_key.since_id_entity, since_id_entity, { saveToLocalStorage: true }

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

_.extend BackgroundMentionsPool::, Backbone.Events

TentStatus.background_mentions_pool = new BackgroundMentionsPool
