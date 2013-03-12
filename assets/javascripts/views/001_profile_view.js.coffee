Marbles.Views.ProfileView = class ProfileView extends TentStatus.View
  constructor: ->
    super
    @profile_cid = Marbles.DOM.attr(@el, 'data-profile_cid')

  fetch: (params = {}, options = {}) =>
    if @profile_cid
      return @render()

    instance = TentStatus.Model.find(cid: @model_cid) if @model_cid

    TentStatus.trigger('loading:start')
    TentStatus.Models.Profile.fetch _.extend(
      entity: instance?.get('entity') || options.entity
    , params), _.extend(
      success: (profile, xhr) =>
        TentStatus.trigger('loading:stop')
        @profile_cid = profile.cid
        @render(@context profile)

        if Marbles.DOM.attr(@el, 'title') == profile.get('entity') && profile.hasName()
          Marbles.DOM.setAttr(@el, 'title', profile.get('name'))

      error: (res, xhr) =>
        TentStatus.trigger('loading:stop')
    , options)

  context: (profile = TentStatus.Model.instances.all[@profile_cid]) =>
    has_name: profile?.hasName() || false
    name: profile?.get('name')
    avatar: profile?.get('avatar') || TentStatus.config.default_avatar
    profile_url: TentStatus.Helpers.entityProfileUrl(profile.get 'entity') if profile
    formatted:
      entity: TentStatus.Helpers.formatUrl(profile.get 'entity') if profile

