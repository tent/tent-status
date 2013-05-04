Marbles.Views.MentionsUnreadCount = class MentionsUnreadCountView extends Marbles.View
  @view_name: 'mentions_unread_count'
  @template_name: 'mentions_unread_count'

  constructor: (options = {}) ->
    super

    @init()

  init: =>
    unless TentStatus.background_mentions_unread_count
      return TentStatus.on 'init:background_mentions_unread_count', @init

    @render()
    TentStatus.background_mentions_unread_count.on 'change:unread_count', => @render()

  context: =>
    unread_count: TentStatus.Helpers.formatCount(TentStatus.background_mentions_unread_count.get('unread_count'), max: 99)

