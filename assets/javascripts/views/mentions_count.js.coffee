TentStatus.Views.mentions_count = new class MentionsCount extends Backbone.View
  initialize: ->
    @setElement document.getElementById('mentions_count')
    return unless @el

    @mentions_pool = TentStatus.background_mentions_pool
    return unless @mentions_pool

    @mentions_pool.on 'change:mentions_count', @updateBadge

  updateBadge: (count) =>
    if count
      @$el.show().text count
    else
      @$el.hide()

