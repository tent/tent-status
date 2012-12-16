TentStatus.Routers.posts = new class PostsRouter extends TentStatus.Router
  routes: {
    "" : "root"
    "posts" : "index"
    "global": "siteFeed"
  }

  actions_titles: {
    'feed' : 'My Feed'
    'siteFeed': 'Site Feed'
  }

  _initAuthorInfoView: =>
    new TentStatus.Views.AuthorInfo el: document.getElementById('author-info')

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
    new TentStatus.Views.Feed
    @_initAuthorInfoView()

  siteFeed: (params) =>
    unless TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true})
    TentStatus.setPageTitle @actions_titles.siteFeed
    new TentStatus.Views.SiteFeed

