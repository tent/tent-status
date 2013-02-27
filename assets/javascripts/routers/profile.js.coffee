TentStatus.Routers.profile = new class ProfileRouter extends Marbles.Router
  routes: {
    "profile" : "currentProfile"
    ":entity/profile" : "profile"
  }

  actions_titles: {
    "currentProfile" : "Profile"
  }

  currentProfile: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/global', {trigger:true, replace: true})

    new Marbles.Views.Profile entity: TentStatus.config.domain_entity.toString()

  profile: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/global', {trigger:true, replace: true})

    new Marbles.Views.Profile entity: params.entity
