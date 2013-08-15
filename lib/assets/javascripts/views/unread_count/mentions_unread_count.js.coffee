Marbles.Views.MentionsUnreadCount = class MentionsUnreadCountView extends Marbles.Views.UnreadCount
  @view_name: 'mentions_unread_count'
  @cursor_post_type: TentStatus.config.POST_TYPES.MENTIONS_CURSOR
  @post_types: [TentStatus.config.POST_TYPES.STATUS_REPLY, TentStatus.config.POST_TYPES.STATUS]

  fetchParams: =>
    params = super
    params.mentions = TentStatus.config.meta.content.entity
    params

