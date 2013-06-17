Marbles.Views.Profile = class ProfileView extends Marbles.View
  @template_name: 'profile'
  @view_name: 'profile'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @fetchMetaProfile(options.entity)

  fetchMetaProfile: (entity) =>
    model = TentStatus.Models.MetaProfile.find(entity: entity, fetch: false) || new TentStatus.Models.MetaProfile(entity: entity)
    @profile_cid = model.cid
    model.fetch {entity: entity},
      failure: (profile, xhr) =>
        @render(@context(profile))

      success: (profile) =>
        @render(@context(profile))

  profile: =>
    TentStatus.Models.MetaProfile.find(cid: @profile_cid, fetch: false)

  context: (profile = @profile()) =>
    profile: profile
    has_name: !!profile.get('name')
    formatted:
      bio: profile.get('bio')
      entity: TentStatus.Helpers.formatUrlWithPath(profile.get('entity'))
      website: TentStatus.Helpers.formatUrlWithPath(profile.get('website'))

