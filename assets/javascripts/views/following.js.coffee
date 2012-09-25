class TentStatus.Views.Following extends TentStatus.View
  templateName: '_following'

  @create: (following, container, parentView) ->
    parentView.followings.unshift(following)
    parentView.render()

  initialize: (options) ->
    @parentView = options.parentView
    super

    @following = options.following
    @following.on 'change:profile', => @render()
    @on 'render', @bindEvents

  bindEvents: =>
    @$fields = {
      unfollow: ($ '.unfollow-btn', @$el)
    }

    @$fields.unfollow.off('click.unfollow').on 'click.unfollow', (e) =>
      return unless @confirmUnfollow()
      @$el.hide()
      @following.destroy
        error: =>
          @$el.show()

  confirmUnfollow: =>
    return false unless @following
    confirm @$fields.unfollow.attr('data-confirm')

  context: (following=@following) =>
    _.extend following.toJSON(), {
      name: following.name()
      avatar: following.avatar()
    }

  render: =>
    return unless html = super
    el = ($ html)
    @$el.replaceWith(el)
    @setElement el
    @trigger 'ready'

