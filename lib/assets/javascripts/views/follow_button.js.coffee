class Marbles.Views.FollowButton extends Marbles.View
  @view_name: 'follow_button'
  @template_name: 'follow_button'

  constructor: (options = {}) ->
    super

    return unless TentStatus.config.authenticated

    @elements = {}
    @text = {}

    @on 'ready', @init

    profile = @profile()
    if TentStatus.config.current_entity.assertEqual(profile.get('entity'))
      @is_self = true
      @render()
    else
      @fetchFollowing(profile)

  fetchFollowing: (profile = @profile()) =>
    TentStatus.Models.Following.find {entity: profile.get('entity')},
      error: (res, xhr) =>
        if xhr.status == 404
          @is_following = false
          @render()

      success: (following) =>
        @following_cid = following.cid
        @is_following = true
        @render()

  init: =>
    @elements.form = Marbles.DOM.querySelector('form', @el)
    @elements.submit = Marbles.DOM.querySelector('input[type=submit]', @el)

    @text.confirm = Marbles.DOM.attr(@elements.submit, 'data-confirm')

    Marbles.DOM.on(@elements.form, 'submit', @confirmSubmit)

  profile: => @parent_view.profile()

  following: => TentStatus.Models.Following.find {cid: @following_cid, fetch: false}

  confirmSubmit: (e) =>
    e?.preventDefault()
    return if @text.confirm && !confirm(@text.confirm)
    @submit()

  submit: =>
    @elements.submit.disabled = true

    if @is_following
      @following().delete
        error: (res, xhr) =>
          @render()

        success: (following) =>
          @is_following = false
          delete @following_cid
          @render()
    else
      TentStatus.Models.Following.create {entity: @profile().get('entity')},
        error: (res, xhr) =>
          @render()

        success: (following) =>
          @is_following = true
          @following_cid = following.cid
          @render()

  context: =>
    profile = @profile()

    is_self: @is_self
    is_following: @is_following
    entity: profile.get('entity')

