class TentStatus.Views.NewFollowingForm extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @$el.on 'submit', @submit

  submit: (e) =>
    e.preventDefault()
    entity = ($ '[name=entity]', @$el).val()
    following = new TentStatus.Models.Following { entity: entity }
    following.once 'sync', =>
      TentStatus.Collections.followings.unshift(following)
      @parentView.render()
    following.save()
    false
