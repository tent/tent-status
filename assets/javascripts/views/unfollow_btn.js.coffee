class StatusApp.Views.UnfollowBtn extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    followingId = @$el.attr 'data-id'
    @following = StatusApp.Collections.followings.get(followingId)

    @confirmMsg = @$el.attr 'data-confirm'

    @$el.on 'click', @confirmUnfollow

  confirmUnfollow: =>
    shouldUnfollow = confirm @confirmMsg
    return unless shouldUnfollow
    @following.destroy
      success: =>
        StatusApp.Collections.followings.remove(@following)
        @parentView.render()
