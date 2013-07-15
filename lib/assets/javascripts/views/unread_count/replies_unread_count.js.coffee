Marbles.Views.RepliesUnreadCount = class RepliesUnreadCountView extends Marbles.Views.UnreadCount
  @view_name: 'replies_unread_count'
  @cursor_post_type: TentStatus.config.POST_TYPES.REPLIES_CURSOR
  @post_types: [TentStatus.config.POST_TYPES.STATUS_REPLY]

  fetchParams: =>
    params = super
    params.mentions = TentStatus.config.meta.entity
    params

