Marbles.Views.RepostsUnreadCount = class RepostsUnreadCountView extends Marbles.Views.UnreadCount
  @view_name: 'reposts_unread_count'
  @cursor_post_type: TentStatus.config.POST_TYPES.REPOSTS_CURSOR
  @post_types: TentStatus.config.repost_types

  fetchParams: =>
    params = super
    params.mentions = TentStatus.config.current_user.entity
    params

