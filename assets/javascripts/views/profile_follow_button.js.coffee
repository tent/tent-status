class StatusApp.Views.ProfileFollowButton extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @buttons = {}
    @buttons.submit = ($ '[type=submit]', @$el)

    following = new StatusApp.Models.Following
    following.fetch
      url: "#{StatusApp.api_root}/followings?entity=#{encodeURIComponent(StatusApp.domain_entity)}&guest=true"
      success: (f, res) =>
        if res.length
          @setFollowing()

    @$el.on 'submit', @submit

  submit: (e) =>
    e.preventDefault()
    entity = StatusApp.domain_entity
    @buttons.submit.attr 'disabled', 'disabled'
    following = new StatusApp.Models.Following { entity: entity }
    following.once 'sync', =>
      @setFollowing()
    following.save()
    false

  setFollowing: =>
    @buttons.submit.val 'Following'
    @buttons.submit.attr 'disabled', 'disabled'
