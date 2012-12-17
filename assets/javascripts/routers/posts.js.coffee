TentStatus.Routers.posts = new class PostsRouter extends TentStatus.Router
  routes: {
    "" : "root"
    "posts" : "index"
    "global": "siteFeed"
    "mentions" : "mentions"
    ":entity/mentions" : "mentions"
    "posts/:id" : "post"
    "posts/:entity/:id" : "post"
  }

  actions_titles: {
    'feed' : 'My Feed'
    'siteFeed': 'Site Feed'
    'post' : 'Conversation'
    'mentions' : 'Mentions'
  }

  _initAuthorInfoView: =>
    new TentStatus.Views.AuthorInfo el: document.getElementById('author-info')

  index: (params) =>
    if TentStatus.config.guest
      return @navigate('/profile', {trigger:true, replace: true})

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
      return @navigate('/', {trigger: true, replace: true})
    TentStatus.setPageTitle @actions_titles.siteFeed
    new TentStatus.Views.SiteFeed

  post: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    TentStatus.setPageTitle @actions_titles.post
    new TentStatus.Views.SinglePost entity: (params.entity || TentStatus.config.domain_entity.toString()), id: params.id

  mentions: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    TentStatus.setPageTitle @actions_titles.mentions
    new TentStatus.Views.Mentions entity: (params.entity || TentStatus.config.domain_entity.toString())

