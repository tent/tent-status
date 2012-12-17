TentStatus.Views.ProfileName = class ProfileNameView extends TentStatus.Views.ProfileView
  @template_name: '_profile_name'
  @view_name: 'profile_name'

  constructor: ->
    super

    @model_cid = DOM.attr(@el, 'data-model_cid')
    @fetch()
