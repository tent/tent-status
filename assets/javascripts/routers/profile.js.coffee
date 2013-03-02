TentStatus.Routers.profile = new class ProfileRouter extends Marbles.Router
  routes: {
    "profile" : "currentProfile"
    ":entity/profile" : "profile"
  }

  actions_titles: {
    "currentProfile" : "Profile"
    "profile" : "Profile"
  }

  currentProfile: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/global', {trigger:true, replace: true})

    new Marbles.Views.Profile entity: TentStatus.config.domain_entity.toString()
    TentStatus.setPageTitle page: @actions_titles.currentProfile

  profile: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/global', {trigger:true, replace: true})

    new Marbles.Views.Profile entity: params.entity
    TentStatus.setPageTitle page: @actions_titles.profile
