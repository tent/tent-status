Marbles.Views.ProfileName = class ProfileNameView extends Marbles.Views.ProfileView
  @template_name: '_profile_name'
  @view_name: 'profile_name'

  constructor: ->
    super

    @model_cid = Marbles.DOM.attr(@el, 'data-model_cid')
    @fetch()
