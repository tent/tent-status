TentStatus.Views.PostProfileAvatar = class PostProfileAvatarView extends TentStatus.Views.ProfileView
  @template_name: '_post_profile_avatar'
  @view_name: 'post_profile_avatar'

  constructor: ->
    super

    @post_cid = DOM.attr(@el, 'data-post_cid')
    @fetch({}, {
      error: =>
        TentStatus.trigger('loading:stop')
        @render()
    })

