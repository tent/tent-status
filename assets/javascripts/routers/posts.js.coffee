StatusPro.Routers.posts = new class PostsRouter extends StatusPro.Router
  routerKey: 'posts'

  routes:
    ""      : "root"
    "posts" : "index"
    "posts/:entity/:post_id" : "conversation"

  index: =>
    @view = new StatusPro.Views.Posts
    @setCurrentAction 'index', =>
      @fetchData 'posts', =>
        { posts: StatusPro.Collections.posts, loaded: false }
      @fetchData 'groups', =>
        { groups: StatusPro.Collections.groups, loaded: false }
      @fetchData 'followers', =>
        { followers: StatusPro.Collections.followers, loaded: false }
      @fetchData 'followings', =>
        { followings: StatusPro.Collections.followings, loaded: false }
      @fetchData 'profile', =>
        { profile: StatusPro.Models.profile, loaded: false }

  root: => @index(arguments...)

  conversation: (entity, post_id) =>
    @view = new StatusPro.Views.Conversation
    @setCurrentAction 'conversation', =>
      @fetchData 'posts', (callback) =>
        _posts = new StatusPro.Collections.Posts
        _post = new StatusPro.Models.Post { id: post_id }

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
        { groups: StatusPro.Collections.groups, loaded: false }
      @fetchData 'followers', =>
        { followers: StatusPro.Collections.followers, loaded: false }
      @fetchData 'followings', =>
        { followings: StatusPro.Collections.followings, loaded: false }
      @fetchData 'profile', =>
        { profile: StatusPro.Models.profile, loaded: false }
