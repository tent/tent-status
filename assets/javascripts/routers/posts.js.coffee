TentStatus.Routers.posts = new class PostsRouter extends TentStatus.Router
  routerKey: 'posts'

  routes:
    ""                 : "root"
    "profile"          : "myProfile"
    "posts"            : "index"
    "entities/:entity"          : "profile"
    "entities/:entity/:post_id" : "conversation"

  index: =>
    unless TentStatus.config.current_entity.hostname == TentStatus.config.domain_entity.hostname
      @profile(encodeURIComponent(TentStatus.domain_entity))
      return
    @view = new TentStatus.Views.Posts
    @setCurrentAction 'index', =>
      @view.render()

  root: => @index(arguments...)

  conversation: (entity, post_id) =>
    @view = new TentStatus.Views.Conversation
    @setCurrentAction 'conversation', =>
      @fetchData 'post', =>
        _post = new TentStatus.Models.Post { id: post_id }
        { post: _post, loaded: false }

      @fetchData 'posts', =>
        query_string = "mentioned_entity=#{entity}&mentioned_post=#{post_id}"
        options =
          url: "#{(new TentStatus.Collections.Posts).url}?#{query_string}"

        _posts = new TentStatus.Paginator( new TentStatus.Collections.Posts, options )
        { posts: _posts, loaded: false }

      @fetchData 'followers', =>
        { followers: new TentStatus.Paginator( TentStatus.Collections.followers ), loaded: false }
      @fetchData 'followings', =>
        { followings: new TentStatus.Paginator( TentStatus.Collections.followings ), loaded: false }
      @fetchData 'profile', =>
        { profile: TentStatus.Models.profile, loaded: false }

  myProfile: =>
    @profile(TentStatus.current_entity)

  profile: (entity) =>
    @view = new TentStatus.Views.Profile
