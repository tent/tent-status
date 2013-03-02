TentStatus.Routers.follows = new class FollowsRouter extends Marbles.Router
  routes: {
    "followings" : "followings"
    ":entity/followings" : "followings"
    "followers" : "followers"
    ":entity/followers" : "followers"
  }

  actions_titles: {
    'followings' : 'Following'
    'followers' : 'Followers'
  }

  followings: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    TentStatus.setPageTitle @actions_titles.followings
    new Marbles.Views.Followings entity: (params.entity || TentStatus.config.domain_entity.toString())

    title = @actions_titles.followings
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title

  followers: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    TentStatus.setPageTitle @actions_titles.followers
    new Marbles.Views.Followers entity: (params.entity || TentStatus.config.domain_entity.toString())

    title = @actions_titles.followers
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title

