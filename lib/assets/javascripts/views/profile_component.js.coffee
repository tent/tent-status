Marbles.Views.ProfileComponent = class ProfileComponentView extends Marbles.View
  constructor: ->
    super

    @entity = Marbles.DOM.attr(@el, 'data-entity')
    @add_title = Marbles.DOM.hasAttr(@el, 'data-title')
    @no_link = Marbles.DOM.hasAttr(@el, 'data-no_link')
    @css_class = Marbles.DOM.attr(@el, 'data-class')

    TentStatus.Models.MetaProfile.on("#{@entity}:fetch:success", @render, null, args: false)
    TentStatus.Models.MetaProfile.on("#{@entity}:fetch:failure", @render, null, args: false)

    model = @profileModel()
    model.on 'change:avatar_url change:name', @render, null, args: false

    if model.get('id')
      @render()
    else
      model.fetch()

  createProfileModel: =>
    new TentStatus.Models.MetaProfile(entity: @entity)

  profileModel: =>
    TentStatus.Models.MetaProfile.find(entity: @entity, fetch: false) || @createProfileModel()

  context: (profile = @profileModel()) =>
    profile: profile
    has_name: !!(profile?.get('name'))
    entity: @entity
    profile_url: TentStatus.Helpers.entityProfileUrl(@entity)
    css_class: @css_class
    title: if @add_title then profile?.get('name') || TentStatus.Helpers.formatUrlWithPath(@entity) else null
    no_link: @no_link
    formatted:
      entity: TentStatus.Helpers.formatUrlWithPath(@entity)

