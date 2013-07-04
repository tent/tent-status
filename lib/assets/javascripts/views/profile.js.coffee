Marbles.Views.Profile = class ProfileView extends Marbles.View
  @template_name: 'profile'
  @view_name: 'profile'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @fetchMetaProfile(options.entity)

  fetchMetaProfile: (entity) =>
    model = TentStatus.Models.MetaProfile.find(entity: entity, fetch: false)

    if model
      @profile_cid = model.cid
      @render(@context(model))
    else
      TentStatus.Models.MetaProfile.fetch(entity,
        success: (model) =>
          @profile_cid = model.cid
          @render(@context(model))

        failure: (res, xhr) =>
          console.warn("No profile found for #{JSON.stringify(entity)}! #{xhr.status} #{res}")
      )

  profile: =>
    TentStatus.Models.MetaProfile.find(cid: @profile_cid, fetch: false)

  context: (profile = @profile()) =>
    profile: profile
    has_name: !!profile.get('name')
    formatted:
      bio: profile.get('bio')
      entity: TentStatus.Helpers.formatUrlWithPath(profile.get('entity'))
      website: TentStatus.Helpers.formatUrlWithPath(profile.get('website'))

