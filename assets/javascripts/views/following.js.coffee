class TentStatus.Views.Following extends TentStatus.View
  templateName: '_following'

  @create: (following, container, parentView) ->
    el = ($ "<tr class='following' data-id='#{following.get('id')}'>")
    container = ($ '.followings tbody', container.$el)
    container.prepend(el)
    view = new TentStatus.Views.Following el: el, parentView: parentView, following: following
    view.render()

  initialize: (options) ->
    @parentView = options.parentView
    @following = options.following
    super

    @on 'render', @bindEvents

  bindEvents: =>
    @$fields = {
      unfollow: ($ '.unfollow-btn', @$el)
    }

    @$fields.unfollow.off('click.unfollow').on 'click.unfollow', (e) =>
      return unless @following
      return unless @confirmUnfollow()
      @$el.hide()
      @following.destroy
        error: =>
          @$el.show()

  confirmUnfollow: =>
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

