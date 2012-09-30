class TentStatus.Views.Profile extends TentStatus.View
  templateName: 'profile'
  partialNames: ['_post', '_post_inner', '_reply_form']

  dependentRenderAttributes: ['profile']

  initialize: (options = {}) ->
    @container = TentStatus.Views.container

    # TODO: handle any entity uri via options.entity

    super

    @on 'change:profile', @render

    TentStatus.trigger 'loading:start'
    new HTTP 'GET', "#{TentStatus.config.current_tent_api_root}/profile", null, (profile, xhr) =>
      TentStatus.trigger 'loading:complete'
      return @render404() unless xhr.status == 200
      @set 'profile', new TentStatus.Models.Profile profile

  notFoundContext: =>
    text: "There is no tent.is user registered with this name"
    subtext: "You can register at <a href='https://tent.is'>Tent.is</a>"

  context: =>
    return {} unless @profile
    _.extend super,
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

