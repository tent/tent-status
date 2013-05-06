Marbles.Views.MiniProfile = class MiniProfileView extends Marbles.View
  @template_name: 'mini_profile'
  @partial_names: []
  @view_name: 'mini_profile'

  constructor: (options = {}) ->
    super

    @fetchProfile(options.entity) if options.entity

    Marbles.Views.Post.on 'focus', (view, e) =>
      return @render() unless view
      Marbles.DOM.setStyle(@el, 'top', "#{Marbles.DOM.offsetTop view.el}px")
      post = view.post()
      entity = if post.get('is_repost') then post.get('content.entity') else post.get('entity')
      @fetchProfile(entity)

  fetchProfile: (entity) =>
    return unless entity
    return if entity == @profile()?.get('entity')
    if profile = TentStatus.Models.BasicProfile.find(entity: entity)
      @current_profile_cid = profile.cid
      @render(@context(profile))
    else
      TentStatus.Models.BasicProfile.fetch({ entity: entity},
        failure: (res, xhr) =>

        success: (profile, xhr) =>
          @current_profile_cid = profile.cid
          @render(@context(profile))
      )

  profile: =>
    TentStatus.Models.BasicProfile.find(cid: @current_profile_cid)

  context: (profile = @profile()) =>
    return { profile: null } unless profile

    profile: profile
    profile_url: TentStatus.Helpers.entityProfileUrl(profile.get('entity'))
    formatted:
      name: TentStatus.Helpers.truncate(profile.get('content.name') || TentStatus.Helpers.formatUrlWithPath(profile.get('entity')), 15)
      bio: TentStatus.Helpers.truncate(profile.get('content.bio'), 256)
      website_url: TentStatus.Helpers.formatUrlWithPath(profile.get('content.website_url'))

