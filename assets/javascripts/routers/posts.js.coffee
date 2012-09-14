StatusApp.Routers.posts = new class PostsRouter extends StatusApp.Router
  routerKey: 'posts'

  routes:
    ""      : "root"
    "posts" : "index"
    "posts/:entity/:post_id" : "conversation"

  index: =>
    @view = new StatusApp.Views.Posts
    window.view = @view
    @setCurrentAction 'index', =>
      @fetchData 'posts', =>
        { posts: new StatusApp.Paginator( StatusApp.Collections.posts ), loaded: false }
      @fetchData 'followers', =>
        { followers: new StatusApp.Paginator( StatusApp.Collections.followers ), loaded: false }
      @fetchData 'followings', =>
        { followings: new StatusApp.Paginator( StatusApp.Collections.followings ), loaded: false }
      @fetchData 'profile', =>
        { profile: StatusApp.Models.profile, loaded: false }

  root: => @index(arguments...)

  conversation: (entity, post_id) =>
    @view = new StatusApp.Views.Conversation
    @setCurrentAction 'conversation', =>
      @fetchData 'post', =>
        _post = new StatusApp.Models.Post { id: post_id }
        { post: _post, loaded: false }

      @fetchData 'posts', =>
        query_string = "mentioned_entity=#{entity}&mentioned_post=#{post_id}"
        options =
          url: "#{(new StatusApp.Collections.Posts).url}?#{query_string}"

        _posts = new StatusApp.Paginator( new StatusApp.Collections.Posts, options )
        { posts: _posts, loaded: false }

      @fetchData 'followers', =>
        { followers: new StatusApp.Paginator( StatusApp.Collections.followers ), loaded: false }
      @fetchData 'followings', =>
        { followings: new StatusApp.Paginator( StatusApp.Collections.followings ), loaded: false }
      @fetchData 'profile', =>
        { profile: StatusApp.Models.profile, loaded: false }
