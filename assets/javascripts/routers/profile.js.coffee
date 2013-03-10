TentStatus.Routers.profile = new class ProfileRouter extends Marbles.Router
  routes: {
    "profile" : "currentProfile"
    ":entity/profile" : "profile"
  }

  actions_titles: {
    "currentProfile" : "Profile"
    "profile" : "Profile"
  }

  _initAuthorInfoView: (options = {}) =>
    new Marbles.Views.AuthorInfo _.extend options,
      el: document.getElementById('author-info')

  currentProfile: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/global', {trigger:true, replace: true})

    new Marbles.Views.Profile entity: TentStatus.config.domain_entity.toString()
    @_initAuthorInfoView()
    TentStatus.setPageTitle page: @actions_titles.currentProfile

  profile: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/global', {trigger:true, replace: true})

    new Marbles.Views.Profile entity: params.entity
    @_initAuthorInfoView()

    title = @actions_titles.profile
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title
