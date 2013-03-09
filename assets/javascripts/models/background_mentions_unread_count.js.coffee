class BackgroundMentionsUnreadCount extends TentStatus.Object
  constructor: ->
    @fetch_interval = new TentStatus.FetchInterval fetch_callback: @fetchMentionsCount

    @on 'change:unread_count', => @fetch_interval.reset()

    @fetch_interval.start()
    @fetchMentionsCount()

  fetchMentionsCount: (options = {}) =>
    if !options.skip_cursor && !TentStatus.background_mentions_cursor
      @fetch_interval.stop()
      return TentStatus.once 'init:background_mentions_cursor', =>
        @fetch_interval.resume()
        @fetchMentionsCount()

    if !options.skip_cursor && !TentStatus.background_mentions_cursor.get('cursor')
      @fetch_interval.stop()
      return TentStatus.background_mentions_cursor.once 'change:cursor', =>
        @fetch_interval.resume()
        @fetchMentionsCount()

    if cursor = TentStatus.background_mentions_cursor.get('cursor.mentions')?[TentStatus.config.POST_TYPES.STATUS]
      pagination_params = {
        since_id: cursor.post
        since_id_entity: cursor.entity
      }
    else
      pagination_params = {}

    client = Marbles.HTTP.TentClient.currentEntityClient()
    params = _.extend pagination_params, {
      mentioned_entity: TentStatus.config.current_entity.toString()
      post_types: TentStatus.config.post_types
    }
    client.head "/posts", params,
      success: (res, xhr) =>
        count = parseInt xhr.getResponseHeader('Count')

        @fetch_interval.increaseDelay()

        @set 'unread_count', count

        options.success?(arguments...)

TentStatus.once 'ready', =>
  TentStatus.background_mentions_unread_count = new BackgroundMentionsUnreadCount
  TentStatus.trigger 'init:background_mentions_unread_count'
