TentStatus.Views.ProfileAvatar = class ProfileAvatarView extends TentStatus.Views.ProfileView
  @template_name: '_profile_avatar'
  @view_name: 'profile_avatar'

  constructor: ->
    super

    @model_cid = DOM.attr(@el, 'data-model_cid')
    @fetch({}, {
      error: =>
        TentStatus.trigger('loading:stop')
        @render()
    })
