class TentStatus.Views.Profile extends TentStatus.View
  templateName: 'profile'
  partialNames: ['_post', '_post_inner', '_reply_form']

  dependentRenderAttributes: ['profile']

  initialize: (options = {}) ->
    @container = TentStatus.Views.container
    @entity = decodeURIComponent(options.entity)

    super

    @on 'change:profile', @render

    TentStatus.trigger 'loading:start'
    if TentStatus.config.domain_entity.assertEqual(@entity)
      new HTTP 'GET', "#{TentStatus.config.domain_tent_api_root}/profile", null, @getProfileComplete
    else
      new HTTP 'GET', "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent(@entity.toStringWithoutSchemePort())}/profile", null, @getProfileComplete

  getProfileComplete: (profile, xhr) =>
    TentStatus.trigger 'loading:complete'
    return @render404() unless xhr.status == 200
    @set 'profile', new TentStatus.Models.Profile profile

  notFoundContext: =>
    if TentStatus.config.tent_host_domain
      text: "There is no #{TentStatus.config.tent_host_domain} user registered with this name"
      subtext: "You can register at <a href='https://#{TentStatus.config.tent_host_domain}'>#{TentStatus.Helpers.capitalize(TentStatus.config.tent_host_domain)}</a>"
    else
      text: "#{@entity} not found"

  context: =>
    return {} unless @profile
    _.extend super,
      entity: @profile.entity()
      profile:
        name: @profile.name()
        bio: @profile.bio()
        avatar: @profile.avatar()
        hasName: @profile.hasName()
        entity: @profile.entity()
        encoded:
          entity: encodeURIComponent(@profile.entity())
        formatted:
          entity: TentStatus.Helpers.formatUrl @profile.entity()

