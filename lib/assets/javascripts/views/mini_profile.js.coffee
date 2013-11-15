Marbles.Views.MiniProfile = class MiniProfileView extends Marbles.View
  @template_name: 'mini_profile'
  @partial_names: []
  @view_name: 'mini_profile'

  constructor: (options = {}) ->
    super

    # Don't show the mini profile when not authenticated
    return unless TentStatus.config.authenticated

    @fetchProfile(options.entity) if options.entity

    @current_post_view = null

    Marbles.Views.Post.on 'focus', (view, e) =>
      return @render() unless view

      @setCurrentPostView(view)

    Marbles.Views.PostsFeed.on 'prepend', => setImmediate(@adjustPosition)

    Marbles.Views.FetchPostsPool.on 'render', => setImmediate(@adjustPosition)

  setCurrentPostView: (view) =>
    @current_post_view = view

    @adjustPosition()

    post = view.post()

    if post.get('is_repost')
      @fetchProfile(post.get('content.entity'))
    else
      @fetchProfile(post.get('entity'))

  adjustPosition: =>
    return unless @current_post_view

    Marbles.DOM.setStyle(@el, 'top', "#{Marbles.DOM.offsetTop(@current_post_view.el)}px")

  fetchProfile: (entity) =>
    return unless entity
    return if entity == @profile()?.get('entity')
    TentStatus.Models.MetaProfile.find({entity: entity},
      success: (profile) =>
        @current_profile_cid = profile.cid
        @render(@context(profile))

      failure: =>
        @render()
    )

  profile: =>
    TentStatus.Models.MetaProfile.find(cid: @current_profile_cid)

  context: (profile = @profile()) =>
    return { profile: null } unless profile

    profile: profile
    profile_url: TentStatus.Helpers.entityProfileUrl(profile.get('entity'))
    formatted:
      name: TentStatus.Helpers.truncate(profile.get('name') || TentStatus.Helpers.formatUrlWithPath(profile.get('entity')), 15)
      bio: TentStatus.Helpers.truncate(profile.get('bio'), 256)
      website: TentStatus.Helpers.formatUrlWithPath(profile.get('website'))

