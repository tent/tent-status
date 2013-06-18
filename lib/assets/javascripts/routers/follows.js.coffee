TentStatus.Routers.follows = new class FollowsRouter extends Marbles.Router
  routes: {
    "following" : "following"
    ":entity/following" : "following"
    "followers" : "followers"
    ":entity/followers" : "followers"
  }

  actions_titles: {
    'following' : 'Following'
    'followers' : 'Followers'
  }

  following: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})

    TentStatus.setPageTitle page: @actions_titles.following

    new Marbles.Views.Following entity: (params.entity || TentStatus.config.domain_entity.toString())

    title = @actions_titles.following
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title

  followers: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})

    TentStatus.setPageTitle page: @actions_titles.followers

    new Marbles.Views.Followers entity: (params.entity || TentStatus.config.domain_entity.toString())

    title = @actions_titles.followers
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title

