TentStatus.Routers.posts = new class PostsRouter extends TentStatus.Router
  routerKey: 'posts'

  routes:
    ""                 : "root"
    "profile"          : "myProfile"
    "global"           : "globalFeed"
    "posts"            : "index"
    "posts/:entity/:post_id" : "conversation"
    "posts/:post_id" : "conversation"
    "mentions" : "mentions"
    ":entity/mentions" : "mentions"
    ":entity/profile" : "profile"

  index: =>
    if !TentStatus.authenticated or (TentStatus.config.current_entity.hostname != TentStatus.config.domain_entity.hostname)
      @profile(encodeURIComponent(TentStatus.domain_entity))
      return

    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()

    @view = new TentStatus.Views.Posts

    TentStatus.setPageTitle 'My feed'

    @setCurrentAction 'index', =>
      @view.render()

  root: => @index(arguments...)

  conversation: (entity, post_id) =>
    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()
    unless post_id
      [post_id, entity] = [entity, TentStatus.config.domain_entity]
    else
      entity = new HTTP.URI decodeURIComponent(entity)
    @view = new TentStatus.Views.Conversation entity: entity, post_id: post_id

  myProfile: =>
    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()

    @profile(TentStatus.config.domain_entity)

  profile: (entity) =>
    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()

    if !entity.isURI
      entity = new HTTP.URI decodeURIComponent(entity)

    if TentStatus.config.current_entity.assertEqual(entity)
      TentStatus.setPageTitle 'Profile'
    else
      TentStatus.setPageTitle "#{TentStatus.Helpers.formatUrl TentStatus.config.domain_entity.toStringWithoutSchemePort()} - Profile"
    @view = new TentStatus.Views.Profile entity: entity

  globalFeed: =>
    unless TentStatus.isAppSubdomain()
      return @navigate('/', {trigger: true})
    TentStatus.setPageTitle "Site Feed"
    @view = new TentStatus.Views.GlobalFeed

  mentions: (entity) =>
    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()
    else if entity
      entity = new HTTP.URI decodeURIComponent(entity)
    else
      entity = TentStatus.config.domain_entity

    if TentStatus.config.domain_entity.assertEqual(entity)
      TentStatus.setPageTitle "Mentions"
    else
      TentStatus.setPageTitle "#{TentStatus.Helpers.formatUrl entity.toStringWithoutSchemePort()} - Mentions"
    @view = new TentStatus.Views.Mentions entity: entity

