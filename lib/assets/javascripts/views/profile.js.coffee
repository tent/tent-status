Marbles.Views.Profile = class ProfileView extends Marbles.View
  @template_name: 'profile'
  @view_name: 'profile'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    @fetchMetaProfile(options.entity)

  fetchMetaProfile: (entity) =>
    model = TentStatus.Models.MetaProfile.find(entity: entity, fetch: false)
    return console.warn("No MetaProfile for #{JSON.stringify(entity)}!") unless model
    @profile_cid = model.cid
    @render(@context(model))

  profile: =>
    TentStatus.Models.MetaProfile.find(cid: @profile_cid, fetch: false)

  context: (profile = @profile()) =>
    profile: profile
    has_name: !!profile.get('name')
    formatted:
      bio: profile.get('bio')
      entity: TentStatus.Helpers.formatUrlWithPath(profile.get('entity'))
      website: TentStatus.Helpers.formatUrlWithPath(profile.get('website'))

