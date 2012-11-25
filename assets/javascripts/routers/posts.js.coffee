TentStatus.Routers.posts = new class PostsRouter extends TentStatus.Router
  routes: {
    "" : "root"
    "posts" : "index"
  }

  actions_titles: {
    'feed' : 'My Feed'
  }

  index: (params) =>
    if TentStatus.config.guest
      return console.log 'guest'

    if TentStatus.config.app_domain
      return TentStatus.redirectToGlobalFeed()

    @feed(arguments...)

  root: =>
    @index(arguments...)

  feed: (params) =>
    TentStatus.setPageTitle @actions_titles.feed
    view = new TentStatus.Views.Feed

