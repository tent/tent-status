StatusApp.Routers.posts = new class PostsRouter extends StatusApp.Router
  routerKey: 'posts'

  routes:
    ""                 : "root"
    "posts"            : "index"
    "entities/:entity"          : "profile"
    "entities/:entity/:post_id" : "conversation"

  index: =>
    unless StatusApp.current_entity == StatusApp.domain_entity
      @profile(encodeURIComponent(StatusApp.domain_entity))
      return
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

  profile: (entity) =>
    @view = new StatusApp.Views.Profile
    @setCurrentAction 'profile', =>
      @fetchData 'currentProfile', (callback) =>
        _loadedCalled = 0
        _loaded = (data) =>
          return unless data
          return if _loadedCalled
          _loadedCalled = true

          _profile = new StatusApp.Models.Profile data
          callback({ currentProfile: _profile, loaded: true })

        _following = new StatusApp.Models.Following entity: decodeURIComponent(entity)
        _following.fetch
          url: "#{StatusApp.api_root}/followings?entity=#{entity}"
          success: =>
            return _loaded(false) unless _profile = _following.toJSON()[0]?.profile
            _loaded _.extend({follow_type: 'followings'}, _profile)

        _follower = new StatusApp.Models.Follower entity: decodeURIComponent(entity)
        _follower.fetch
          url: "#{StatusApp.api_root}/followers?entity=#{entity}"
          success: =>
            return _loaded(false) unless _profile = _follower.toJSON()[0]?.profile
            _loaded _.extend({follow_type: 'followers'}, _profile)

        @fetchData 'profile', (profileCallback) =>
          StatusApp.Models.profile.fetch
            success: (profile) =>
              if profile.entity() == decodeURIComponent(entity)
                _loadedCalled = true
                callback({ currentProfile: profile, loaded: true })
              profileCallback({ profile: StatusApp.Models.profile, loaded: true })

      @fetchData 'posts', (callback) =>
        options = { url: "#{StatusApp.api_root}/posts?entity=#{entity}" }
        _posts = new StatusApp.Paginator( new StatusApp.Collections.Posts, options )
        callback({ posts: _posts, loaded: false })

      @fetchData 'followers', =>
        { followers: new StatusApp.Paginator( StatusApp.Collections.followers ), loaded: false }
      @fetchData 'followings', =>
        { followings: new StatusApp.Paginator( StatusApp.Collections.followings ), loaded: false }

