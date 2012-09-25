class TentStatus.Views.Follower extends TentStatus.View
  templateName: '_follower'

  initialize: (options = {}) ->
    @parentView = options.parentView
    @follower = options.follower

    @follower.on 'change:profile', => @render()
    @on 'ready', @initRemoveFollowerBtn

  initRemoveFollowerBtn: =>
    @$fields ?= {}
    @$fields.remove_button = ($ '.remove-follower', @$el)
    @$fields.remove_button.off('click.remove-follower').on 'click.remove-follower', @removeFollower

  removeFollower: =>
    return unless @confirmRemoveFollower()
    @$el.hide()
    @follower.destroy
      error: =>
        @$el.show()

  confirmRemoveFollower: =>
    return false unless @follower
    confirm @$fields.remove_button.attr('data-confirm')

  context: (follower = @follower) =>
    _.extend follower.toJSON(), {
      name: follower.name()
      avatar: follower.avatar()
    }
