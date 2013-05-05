Marbles.Views.Profile = class ProfileView extends Marbles.View
  @template_name: 'profile'
  @view_name: 'profile'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @fetchBasicProfile(options.entity)

  fetchBasicProfile: (entity) =>
    model = TentStatus.Models.BasicProfile.find(entity: entity, fetch: false) || new TentStatus.Models.BasicProfile(entity: entity)
    @profile_cid = model.cid
    model.fetch {entity: entity},
      failure: (profile, xhr) =>
        @render(@context(profile))

      success: (profile) =>
        @render(@context(profile))

  profile: =>
    TentStatus.Models.BasicProfile.find(cid: @profile_cid, fetch: false)

  context: (profile = @profile()) =>
    profile: profile
    has_name: !!profile.get('content.name')
    formatted:
      bio: profile.get('content.bio')
      entity: TentStatus.Helpers.formatUrlWithPath(profile.get('entity'))
      website_url: TentStatus.Helpers.formatUrlWithPath(profile.get('content.website_url'))

