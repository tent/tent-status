TentStatus.Views.ProfileView = class ProfileView extends TentStatus.View
  fetch: (params = {}, options = {}) =>
    instance = TentStatus.Model.find(cid: @model_cid)

    TentStatus.trigger('loading:start')
    TentStatus.Models.Profile.fetch _.extend(
      entity: instance.get('entity')
    , params), _.extend(
      success: (profile, xhr) =>
        TentStatus.trigger('loading:stop')
        @profile_cid = profile.cid
        @render(@context profile)

      error: (res, xhr) =>
        TentStatus.trigger('loading:stop')
    , options)

  context: (profile = TentStatus.Models.Profile.find(cid: @profile_cid)) =>
    has_name: profile?.hasName() || false
    name: profile?.get('name')
    avatar: profile?.get('avatar') || TentStatus.config.default_avatar
    profile_url: TentStatus.Helpers.entityProfileUrl(profile.get 'entity') if profile
    formatted:
      entity: TentStatus.Helpers.formatUrl(profile.get 'entity') if profile

