TentStatus.Routers.profile = new class ProfileRouter extends Marbles.Router
  routes: {
    "profile" : "currentProfile"
    ":entity/profile" : "profile"
  }

  actions_titles: {
    "currentProfile" : "Profile"
    "profile" : "Profile"
  }

  _initMiniProfileView: (options = {}) =>
    new Marbles.Views.MiniProfile _.extend options,
      el: document.getElementById('author-info')

  currentProfile: (params) =>
    new Marbles.Views.Profile entity: TentStatus.config.meta.content.entity
    @_initMiniProfileView()
    TentStatus.setPageTitle page: @actions_titles.currentProfile

  profile: (params) =>
    new Marbles.Views.Profile entity: params.entity
    @_initMiniProfileView()

    title = @actions_titles.profile
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title
