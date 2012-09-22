class TentStatus.Views.ProfileFollowButton extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @buttons = {}
    @buttons.submit = ($ '[type=submit]', @$el)

    @$el.on 'submit', @submit

  submit: (e) =>
    e.preventDefault()
    entity = TentStatus.domain_entity
    @buttons.submit.attr 'disabled', 'disabled'
    following = new TentStatus.Models.Following { entity: entity }
    following.once 'sync', =>
      @setFollowing()
    following.save()
    false

  setFollowing: =>
    @buttons.submit.val 'Following'
    @buttons.submit.attr 'disabled', 'disabled'
