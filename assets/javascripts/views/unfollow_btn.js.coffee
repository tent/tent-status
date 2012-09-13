class StatusPro.Views.UnfollowBtn extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    followingId = @$el.attr 'data-id'
    @following = StatusPro.Collections.followings.get(followingId)

    @confirmMsg = @$el.attr 'data-confirm'

    @$el.on 'click', @confirmUnfollow

  confirmUnfollow: =>
    shouldUnfollow = confirm @confirmMsg
    return unless shouldUnfollow
    @following.destroy
      success: =>
        StatusPro.Collections.followings.remove(@following)
        @parentView.render()
