StatusPro.Routers.posts = new class PostsRouter extends StatusPro.Router
  routerKey: 'posts'

  routes:
    ""      : "root"
    "posts" : "index"

  index: =>
    @view = new StatusPro.Views.Posts
    @setCurrentAction 'index', =>
      @fetchData 'posts', =>
        { posts: StatusPro.Collections.posts, loaded: false }
      @fetchData 'groups', =>
        { groups: StatusPro.Collections.groups, loaded: false }
      @fetchData 'followers', =>
        { followers: StatusPro.Collections.followers, loaded: false }

  root: => @index(arguments...)
