Marbles.Views.ProfileAvatar = class ProfileAvatarView extends Marbles.Views.ProfileView
  @template_name: '_profile_avatar'
  @view_name: 'profile_avatar'

  constructor: ->
    super

    @model_cid = Marbles.DOM.attr(@el, 'data-model_cid')
    @fetch({}, {
      error: =>
        TentStatus.trigger('loading:stop')
        @render()
      entity: Marbles.DOM.attr(@el, 'data-entity') unless @model_cid || @profile_model_cid
    })
