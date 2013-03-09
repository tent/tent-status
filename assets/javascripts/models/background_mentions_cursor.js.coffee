class BackgroundMentionsCursor extends TentStatus.Object
  constructor: ->
    client = Marbles.HTTP.TentClient.currentEntityClient()
    client.get "/profile/#{encodeURIComponent TentStatus.config.PROFILE_TYPES.CURSOR}", null,
      success: (res, xhr) =>
        reset = false
        for type in TentStatus.config.post_types
          unless res.mentions?[type]
            @resetProfileCursor(type, res)
            reset = true

        unless reset
          @set('cursor', res)

      error: (res, xhr) =>
        if xhr.status == 404
          @resetProfileCursor()

  resetProfileCursor: (type, cursor) =>
    unless TentStatus.background_mentions_unread_count
      return TentStatus.once('init:background_mentions_unread_count', => @resetProfileCursor(arguments...))

    TentStatus.background_mentions_unread_count.fetchMentionsCountForType type, cursor,
      success: (type, res, xhr) =>
        link_header = new TentStatus.PaginationLinkHeader xhr.getResponseHeader('Link')

        return unless link_header.pagination_params.prev

        @updateProfileCursor(type, cursor, link_header)

  updateProfileCursor: (type, cursor, link_header) =>

    # reset mentions unread count
    unless TentStatus.background_mentions_unread_count
      return TentStatus.once 'init:background_mentions_unread_count', => @updateProfileCursor(arguments...)
    short_type = TentStatus.Helpers.shortType(type)
    TentStatus.background_mentions_unread_count.set("unread_count:#{short_type}", 0)

    return unless link_header.pagination_params.prev

    cursor ?= {}
    cursor.mentions ?= {}
    cursor.mentions[type] = {
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
