TentStatus.Views.Profile = class ProfileView extends TentStatus.View
  @template_name: 'profile'
  @view_name: 'profile'

  constructor: (options = {}) ->
    @container = TentStatus.Views.container
    super

    @fetchProfile(options.entity)

  fetchProfile: (entity) =>
    TentStatus.Models.Profile.fetch {entity: entity},
      error: (res, xhr) =>

      success: (profile) =>
        @profile_cid = profile.cid
        @render(@context(profile))

  profile: =>
    TentStatus.Models.Profile.find(cid: @profile_cid, fetch: false)

  context: (profile = @profile()) =>
    _.extend TentStatus.Views.AuthorInfo::context.apply(@, arguments),
      has_name: !!profile.get('name')
      formatted:
        name: profile.get('name') || TentStatus.Helpers.formatUrlWithPath(profile.get('entity'))
        bio: profile.get('bio')
        entity: TentStatus.Helpers.formatUrlWithPath(profile.get('entity'))
        website_url: TentStatus.Helpers.formatUrlWithPath(profile.get('website_url'))
