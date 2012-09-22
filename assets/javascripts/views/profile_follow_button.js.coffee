class TentStatus.Views.ProfileFollowButton extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @buttons = {}
    @buttons.submit = ($ '[type=submit]', @$el)

    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/followings", {
      entity: TentStatus.config.domain_entity
    }, (followings, xhr) =>
      return unless xhr.status == 200
      if followings.length
        @setFollowing()

    @$el.on 'submit', @submit

  submit: (e) =>
    e.preventDefault()
    entity = TentStatus.config.domain_entity.toString()
    @buttons.submit.attr 'disabled', 'disabled'
    new HTTP 'POST', "#{TentStatus.config.tent_api_root}/followings", { entity: entity }, (following, xhr) =>
      unless xhr.status == 200
        @buttons.submit.removeAttr 'disabled'
        return
      @setFollowing()

  setFollowing: =>
    @buttons.submit.val 'Following'
    @buttons.submit.attr 'disabled', 'disabled'
