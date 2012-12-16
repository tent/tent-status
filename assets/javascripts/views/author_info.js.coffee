TentStatus.Views.AuthorInfo = class AuthorInfoView extends TentStatus.View
  @template_name: 'author_info'
  @partial_names: []
  @view_name: 'author_info'

  constructor: (options = {}) ->
    super

    @fetchProfile()

    TentStatus.Views.Post.on 'click', (view, e) =>
      DOM.setStyle(@el, 'top', "#{view.el.offsetTop}px")
      @fetchProfile(view.post().get('entity'))

  fetchProfile: (entity = TentStatus.config.current_entity.toString()) =>
    return if entity == @profile()?.get('entity')
    TentStatus.Models.Profile.fetch {entity: entity},
      error: (res, xhr) =>

      success: (profile) =>
        @current_profile_cid = profile.cid
        @render(@context(profile))

  profile: =>
    TentStatus.Models.Profile.find(cid: @current_profile_cid)

  context: (profile = @profile()) =>
    _.extend super, profile.toJSON(),
      name: profile.get('name') || TentStatus.Helpers.formatUrlWithPath(profile.get('entity'))
      avatar: profile.get('avatar') || TentStatus.config.default_avatar
      profile_url: TentStatus.Helpers.entityProfileUrl(profile.get('entity'))
      formatted:
        name: TentStatus.Helpers.truncate(profile.get('name') || TentStatus.Helpers.formatUrlWithPath(profile.get('entity')), 22)
        bio: TentStatus.Helpers.truncate(profile.get('bio'), 256)
        website_url: TentStatus.Helpers.formatUrlWithPath(profile.get('website_url'))

