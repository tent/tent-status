TentStatus.Routers.posts = new class PostsRouter extends TentStatus.Router
  routerKey: 'posts'

  routes:
    ""                 : "root"
    "profile"          : "myProfile"
    "posts"            : "index"
    "posts/:entity/:post_id" : "conversation"
    "posts/:post_id" : "conversation"

  index: =>
    unless TentStatus.config.current_entity.hostname == TentStatus.config.domain_entity.hostname
      @profile(encodeURIComponent(TentStatus.domain_entity))
      return
    @view = new TentStatus.Views.Posts
    @setCurrentAction 'index', =>
      @view.render()

  root: => @index(arguments...)

  conversation: (entity, post_id) =>
    unless post_id
      [post_id, entity] = [entity, TentStatus.config.domain_entity]
    else
      entity = new HTTP.URI decodeURIComponent(entity)
    @view = new TentStatus.Views.Conversation entity: entity, post_id: post_id

  myProfile: =>
    @profile(TentStatus.current_entity)

  profile: (entity) =>
    @view = new TentStatus.Views.Profile entity: entity
