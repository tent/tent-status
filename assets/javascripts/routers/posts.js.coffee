TentStatus.Routers.posts = new class PostsRouter extends Marbles.Router
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
    new Marbles.Views.AuthorInfo el: document.getElementById('author-info')

  index: (params) =>
    if TentStatus.config.guest
      return @navigate('/profile', {trigger:true, replace: true})

    if TentStatus.config.app_domain
      return TentStatus.redirectToGlobalFeed()

    @feed(arguments...)

  root: =>
    @index(arguments...)

  feed: (params) =>
    new Marbles.Views.Feed
    @_initAuthorInfoView()
    TentStatus.setPageTitle page: @actions_titles.feed

  siteFeed: (params) =>
    unless TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    new Marbles.Views.SiteFeed
    @_initAuthorInfoView()
    TentStatus.setPageTitle page: @actions_titles.siteFeed

  post: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    new Marbles.Views.SinglePost entity: (params.entity || TentStatus.config.domain_entity.toString()), id: params.id
    @_initAuthorInfoView()
    TentStatus.setPageTitle page: @actions_titles.post

  mentions: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    new Marbles.Views.Mentions entity: (params.entity || TentStatus.config.domain_entity.toString())
    @_initAuthorInfoView()
    TentStatus.setPageTitle page: @actions_titles.mentions

