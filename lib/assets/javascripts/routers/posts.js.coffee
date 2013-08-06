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

  root: =>
    @index(arguments...)

  feed: (params) =>
    new Marbles.Views.Feed
    @_initMiniProfileView(entity: TentStatus.config.meta.content.entity)
    TentStatus.setPageTitle page: @actions_titles.feed

  siteFeed: (params) =>
    unless TentStatus.config.services.site_feed_api_root
      @navigate(TentStatus.Helpers.route('root'), trigger: true, replace: true)

    new Marbles.Views.SiteFeed
    @_initMiniProfileView()
    TentStatus.setPageTitle page: @actions_titles.siteFeed

  post: (params) =>
    entity = params.entity || TentStatus.config.meta.content.entity
    new Marbles.Views.SinglePost entity: entity, id: params.id
    @_initMiniProfileView(entity: entity)
    TentStatus.setPageTitle page: @actions_titles.post

  replies: (params) =>
    params.entity ?= TentStatus.config.meta.content.entity
    new Marbles.Views.Replies(entity: params.entity)
    @_initMiniProfileView(entity: params.entity)
    TentStatus.setPageTitle page: @actions_titles.replies

  reposts: (params) =>
    params.entity ?= TentStatus.config.meta.content.entity
    new Marbles.Views.Reposts(entity: params.entity)
    @_initMiniProfileView(entity: params.entity)
    TentStatus.setPageTitle page: @actions_titles.reposts

