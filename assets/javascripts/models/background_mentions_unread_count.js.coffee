class BackgroundMentionsUnreadCount extends TentStatus.Object
  constructor: (options = {}) ->
    return if options.initialize_only == true

    @fetch_interval = new TentStatus.FetchInterval fetch_callback: @fetchMentionsCount

    for type in TentStatus.config.post_types
      short_type = TentStatus.Helpers.shortType(type)
      @on "change:unread_count:#{short_type}", @updateUnreadCount
      @on "change:unread_count:#{short_type}", @fetch_interval.resetDelay

    @fetch_interval.start()
    @fetchMentionsCount()

  updateUnreadCount: =>
    full_count = 0
    for type in TentStatus.config.post_types
      short_type = TentStatus.Helpers.shortType(type)
      count = @get("unread_count:#{short_type}")
      full_count += count if count
    @set 'unread_count', full_count

  fetchMentionsCount: (options = {}) =>
    @fetch_interval.stop()

    if !options.skip_cursor && !TentStatus.background_mentions_cursor
      return TentStatus.once 'init:background_mentions_cursor', => @fetchMentionsCount(options)

    if !options.skip_cursor && !TentStatus.background_mentions_cursor.get('cursor')
      return TentStatus.background_mentions_cursor.once 'change:cursor', => @fetchMentionsCount(options)

    cursor = TentStatus.background_mentions_cursor.get('cursor')

    callbacks_remaining = TentStatus.config.post_types.length
    callback = (type, count) =>
      callbacks_remaining--

      short_type = TentStatus.Helpers.shortType(type)
      @set "unread_count:#{short_type}", count if short_type

      if callbacks_remaining == 0
        @fetch_interval.increaseDelay()
        @fetch_interval.resume()

    for type in TentStatus.config.post_types
      @fetchMentionsCountForType(type, cursor, callback)

  fetchMentionsCountForType: (type, cursor, callback) =>
    if cursor = cursor?.mentions?[type]
      pagination_params = {
        since_id: cursor.post
        since_id_entity: cursor.entity
      }
    else
      pagination_params = {}


    client = Marbles.HTTP.TentClient.currentEntityClient()
    params = _.extend pagination_params, {
      mentioned_entity: TentStatus.config.current_entity.toString()
      post_types: [type]
    }
    client.head "/posts", params,
      success: (res, xhr) =>
        count = parseInt xhr.getResponseHeader('Count')
        callback?(type, count)
        callback.success?(type, res, xhr)

      error: (res, xhr) =>
        callback?(type, 0)
        callback.error?(type, res, xhr)

TentStatus.initBackgroundMentionsUnreadCount = (options) ->
  TentStatus.background_mentions_unread_count = new BackgroundMentionsUnreadCount(options)
  TentStatus.trigger 'init:background_mentions_unread_count'
