TentStatus.Routers.follows = new class FollowsRouter extends Marbles.Router
  routes: {
    "subscriptions"         : "subscriptions"
    ":entity/subscriptions" : "subscriptions"
    "subscribers"           : "subscribers"
    ":entity/subscribers"   : "subscribers"
  }

  actions_titles: {
    'subscriptions' : 'Subscriptions'
    'subscribers' : 'Subscribers'
  }

  subscriptions: (params) =>
    new Marbles.Views.Subscriptions entity: (params.entity || TentStatus.config.meta.content.entity)

    title = @actions_titles.subscriptions
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title

  subscribers: (params) =>
    new Marbles.Views.Subscribers entity: (params.entity || TentStatus.config.meta.content.entity)

    title = @actions_titles.subscribers
    title = "#{TentStatus.Helpers.formatUrlWithPath(params.entity)} - #{title}" if params.entity
    TentStatus.setPageTitle page: title

