class StatusPro.Views.RemoveFollowerBtn extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    followerId = @$el.attr 'data-id'
    @follower = StatusPro.Collections.followers.get(followerId)

    @confirmMsg = @$el.attr 'data-confirm'

    @$el.on 'click', @confirmUnfollow

  confirmUnfollow: =>
    shouldRemove = confirm @confirmMsg
    return unless shouldRemove
    @follower.destroy
      success: =>
        StatusPro.Collections.followers.remove(@follower)
        @parentView.render()
