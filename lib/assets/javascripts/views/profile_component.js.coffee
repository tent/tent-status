Marbles.Views.ProfileComponent = class ProfileComponentView extends Marbles.View
  constructor: ->
    super
    @entity = Marbles.DOM.attr(@el, 'data-entity')

  profileModel: =>
    TentStatus.Models.BasicProfile.find(entity: @entity, fetch: false)

  fetch: =>
    if model = @profileModel()
      @render(@context(model))
    else
      @render() # show something while we wait

      model = new TentStatus.Models.BasicProfile(entity: @entity)
      TentStatus.trigger('loading:start')
      model.fetch {entity: @entity},
        failure: (model, xhr) =>
          @render()

        success: (model, xhr) =>
          @render(@context(model))

          if Marbles.DOM.attr(@el, 'title') is @entity && (name = model.get('content.name'))
            Marbles.DOM.setAttr(@el, 'title', name)

        complete: => TentStatus.trigger('loading:stop')

  context: (profile = @profileModel()) =>
    profile: profile
    has_name: !!(profile?.get('content.name'))
    entity: @entity
    profile_url: TentStatus.Helpers.entityProfileUrl(@entity)
    formatted:
      entity: TentStatus.Helpers.formatUrlWithPath(@entity)

