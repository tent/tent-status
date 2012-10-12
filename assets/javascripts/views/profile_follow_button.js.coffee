class TentStatus.Views.ProfileFollowButton extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @buttons = {}
    @buttons.submit = ($ '[type=submit]', @$el)

    @$entity = ($ '[name=entity]', @$el)
    @entity = @$entity.val()

    @hide()

    @setFollowing() if @$el.attr('data-following') == 'true'
    unless @is_following
      @current_entity = @parentView.entity
      if @entity == TentStatus.config.current_entity.toStringWithoutSchemePort()
        @buttons.submit.attr 'disabled', 'disabled'
        @buttons.submit.val 'You'
        @show()
      else
        new HTTP 'GET', "#{TentStatus.config.tent_api_root}/followings", {
          entity: @entity
        }, (followings, xhr) =>
          return unless xhr.status == 200
          if followings.length
            @following_id = followings[0].id
            @setFollowing()
          @show()

    @$el.on 'submit', @submit

  submit: (e) =>
    e.preventDefault()
    if @is_following
      return unless confirm("Unfollow?")
      path = "/#{@following_id}"
    else
      path = ''
    @buttons.submit.attr 'disabled', 'disabled'
    method = if @is_following then 'DELETE' else 'POST'
    new HTTP method, "#{TentStatus.config.tent_api_root}/followings#{path}", { entity: @entity }, (following, xhr) =>
      unless xhr.status == 200
        @buttons.submit.removeAttr 'disabled'
        return
      @following_id = following.id if !@is_following
      if @is_following then @unsetFollowing() else @setFollowing()

  setFollowing: =>
    @is_following = true
    @buttons.submit.val 'Unfollow'
    @buttons.submit.removeClass('blue').addClass('red')
    @buttons.submit.removeAttr 'disabled'
    @show()

  unsetFollowing: =>
    @is_following = false
    @buttons.submit.val 'Follow'
    @buttons.submit.removeClass('red').addClass('blue')
    @buttons.submit.removeAttr 'disabled'
    @show()

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

