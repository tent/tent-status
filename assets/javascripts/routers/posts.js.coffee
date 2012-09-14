StatusApp.Routers.posts = new class PostsRouter extends StatusApp.Router
  routerKey: 'posts'

  routes:
    ""      : "root"
    "posts" : "index"
    "posts/:entity/:post_id" : "conversation"

  index: =>
    @view = new StatusApp.Views.Posts
    @setCurrentAction 'index', =>
      @fetchData 'posts', =>
        { posts: StatusApp.Collections.posts, loaded: false }
      @fetchData 'groups', =>
        { groups: StatusApp.Collections.groups, loaded: false }
      @fetchData 'followers', =>
        { followers: StatusApp.Collections.followers, loaded: false }
      @fetchData 'followings', =>
        { followings: StatusApp.Collections.followings, loaded: false }
      @fetchData 'profile', =>
        { profile: StatusApp.Models.profile, loaded: false }

  root: => @index(arguments...)

  conversation: (entity, post_id) =>
    @view = new StatusApp.Views.Conversation
    @setCurrentAction 'conversation', =>
      @fetchData 'posts', (callback) =>
        _posts = new StatusApp.Collections.Posts
        _post = new StatusApp.Models.Post { id: post_id }

        _n_loaded = 0
        _loaded = =>
          _n_loaded++
          return unless _n_loaded == 2
          _posts.unshift(_post)
          callback({ posts: _posts, loaded: true })

        query_string = "mentioned_entity=#{entity}&mentioned_post=#{post_id}"
        _posts.fetch
          url: _posts.url + "?#{query_string}"
          success: _loaded

        _post.fetch { success: _loaded }

      @fetchData 'groups', =>
        { groups: StatusApp.Collections.groups, loaded: false }
      @fetchData 'followers', =>
        { followers: StatusApp.Collections.followers, loaded: false }
      @fetchData 'followings', =>
        { followings: StatusApp.Collections.followings, loaded: false }
      @fetchData 'profile', =>
        { profile: StatusApp.Models.profile, loaded: false }
