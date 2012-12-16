TentStatus.Routers.profile = new class ProfileRouter extends TentStatus.Router
  routes: {
    "profile" : "currentProfile"
  }

  actions_titles: {
    "currentProfile" : "Profile"
  }

  currentProfile: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/global', {trigger:true})

    new TentStatus.Views.Profile entity: TentStatus.config.domain_entity.toString()
