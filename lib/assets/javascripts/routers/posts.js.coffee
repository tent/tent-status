TentStatus.Routers.posts = new class PostsRouter extends Marbles.Router
  routes: {
    ""                   : "root"
    "posts"              : "index"
    "site-feed"          : "siteFeed"
    "replies"            : "replies"
    "reposts"            : "reposts"
    "posts/:id"          : "post"
    "posts/:entity/:id"  : "post"
  }

  actions_titles: {
    'feed'      : 'My Feed'
    'siteFeed'  : 'Site Feed'
    'post'      : 'Conversation'
    'replies'   : 'Replies'
    'reposts'   : 'Reposts'
  }

  _initMiniProfileView: (options = {}) =>
    new Marbles.Views.MiniProfile _.extend options,
      el: document.getElementById('author-info')

  index: (params) =>
    if TentStatus.config.guest
      return @navigate('/profile', {trigger:true, replace: true})

    @feed(arguments...)

    TentStatus.initBackgroundMentionsCursor()
    TentStatus.initBackgroundMentionsUnreadCount()

  root: =>
    @index(arguments...)

  feed: (params) =>
    new Marbles.Views.Feed
    @_initMiniProfileView(entity: TentStatus.config.current_user.entity)
    TentStatus.setPageTitle page: @actions_titles.feed

  siteFeed: (params) =>
    unless TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    new Marbles.Views.SiteFeed
    @_initMiniProfileView()
    TentStatus.setPageTitle page: @actions_titles.siteFeed

    TentStatus.initBackgroundMentionsCursor()
    TentStatus.initBackgroundMentionsUnreadCount()

  post: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    entity = params.entity || TentStatus.config.domain_entity.toString()
    new Marbles.Views.SinglePost entity: entity, id: params.id
    @_initMiniProfileView(entity: entity)
    TentStatus.setPageTitle page: @actions_titles.post

    TentStatus.initBackgroundMentionsCursor()
    TentStatus.initBackgroundMentionsUnreadCount()

  replies: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    params.entity ?= TentStatus.config.domain_entity
    new Marbles.Views.Replies(entity: params.entity)
    @_initMiniProfileView(entity: params.entity)
    TentStatus.setPageTitle page: @actions_titles.replies

  reposts: (params) =>
    if TentStatus.Helpers.isAppSubdomain()
      return @navigate('/', {trigger: true, replace: true})
    params.entity ?= TentStatus.config.domain_entity
    new Marbles.Views.Reposts(entity: params.entity)
    @_initMiniProfileView(entity: params.entity)
    TentStatus.setPageTitle page: @actions_titles.reposts

