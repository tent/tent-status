Marbles.Views.ProfileComponent = class ProfileComponentView extends Marbles.View
  constructor: ->
    super
    @entity = Marbles.DOM.attr(@el, 'data-entity')

  profileModel: =>
    TentStatus.Models.MetaProfile.find(entity: @entity, fetch: false)

  fetch: =>
    if model = @profileModel()
      @render(@context(model))
    else
      # TODO: request profiles with feed
      model = new TentStatus.Models.MetaProfile(entity: @entity)
      @render()

  context: (profile = @profileModel()) =>
    profile: profile
    has_name: !!(profile?.get('name'))
    entity: @entity
    profile_url: TentStatus.Helpers.entityProfileUrl(@entity)
    formatted:
      entity: TentStatus.Helpers.formatUrlWithPath(@entity)

