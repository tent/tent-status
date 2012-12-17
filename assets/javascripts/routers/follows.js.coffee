TentStatus.Routers.follows = new class FollowsRouter extends TentStatus.Router
  routes: {
    "followings" : "followings"
    ":entity/followings" : "followings"
  }

  actions_titles: {
    'followings' : 'Following'
  }

  followings: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    TentStatus.setPageTitle @actions_titles.followings
    new TentStatus.Views.Followings entity: (params.entity || TentStatus.config.domain_entity.toString())

