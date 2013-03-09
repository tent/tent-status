class BackgroundMentionsCursor extends TentStatus.Object
  constructor: ->
    client = Marbles.HTTP.TentClient.currentEntityClient()
    client.get "/profile/#{encodeURIComponent TentStatus.config.PROFILE_TYPES.CURSOR}", null,
      success: (res, xhr) =>
        if !res.mentions || !res.mentions[TentStatus.config.POST_TYPES.STATUS]
          @resetProfileCursor(res)
        else
          @set('cursor', res)

      error: (res, xhr) =>
        if xhr.status == 404
          @resetProfileCursor()

  resetProfileCursor: (cursor) =>
    unless TentStatus.background_mentions_unread_count
      return TentStatus.once('init:background_mentions_unread_count', @initializeProfileCursor)

    TentStatus.background_mentions_unread_count.fetchMentionsCount
      skip_cursor: true
      success: (res, xhr) =>
        link_header = new TentStatus.PaginationLinkHeader xhr.getResponseHeader('Link')

        return unless link_header.pagination_params.prev

        @updateProfileCursor(cursor, link_header)

  updateProfileCursor: (cursor, link_header) =>

    # reset mentions unread count
    unless TentStatus.background_mentions_unread_count
      return TentStatus.once 'init:background_mentions_unread_count', => @updateProfileCursor(cursor, link_header)
    TentStatus.background_mentions_unread_count.set('unread_count', 0)

    return unless link_header.pagination_params.prev

    cursor ?= {}
    cursor.mentions ?= {}
    cursor.mentions[TentStatus.config.POST_TYPES.STATUS] = {
      post: link_header.pagination_params.prev.since_id
      entity: link_header.pagination_params.prev.since_id_entity
    }

    client = Marbles.HTTP.TentClient.currentEntityClient()
    client.put "/profile/#{encodeURIComponent TentStatus.config.PROFILE_TYPES.CURSOR}", cursor,
      success: (res, xhr) =>
        @set 'cursor', cursor

TentStatus.once 'ready', =>
  TentStatus.background_mentions_cursor = new BackgroundMentionsCursor
  TentStatus.trigger 'init:background_mentions_cursor'
