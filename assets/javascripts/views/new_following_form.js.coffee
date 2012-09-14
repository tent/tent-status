class StatusApp.Views.NewFollowingForm extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @$el.on 'submit', @submit

  submit: (e) =>
    e.preventDefault()
    entity = ($ '[name=entity]', @$el).val()
    following = new StatusApp.Models.Following { entity: entity }
    following.once 'sync', =>
      StatusApp.Collections.followings.unshift(following)
      @parentView.render()
    following.save()
    false
