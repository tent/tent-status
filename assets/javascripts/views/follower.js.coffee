class TentStatus.Views.Follower extends TentStatus.View
  templateName: '_follower'

  initialize: (options = {}) ->
    @parentView = options.parentView
    @follower = options.follower
    @entity = @parentView.entity

    @follower.on 'change:profile', => @render()
    @on 'ready', @initRemoveFollowerBtn

    super

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

  context: (follower = @follower, entity = @entity) =>
    _.extend follower.toJSON(), super, {
      name: follower.name() || follower.get('entity')
      avatar: follower.avatar()
      hasName: follower.hasName()
      profileUrl: TentStatus.Helpers.entityProfileUrl follower.get('entity')
      guest_authenticated: TentStatus.guest_authenticated || !TentStatus.config.domain_entity.assertEqual(entity)
    }

  renderHTML: (context, partials, template = (@template || partials['_follower'])) =>
    template.render(context, partials)

  render: =>
    html = @renderHTML(@context(), @parentView.partials)
    el = ($ html)
    @$el.replaceWith(el)
    @setElement el
    @trigger 'ready'

