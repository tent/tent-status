TentStatus.Routers.posts = new class PostsRouter extends TentStatus.Router
  routerKey: 'posts'

  routes:
    ""                 : "root"
    "profile"          : "myProfile"
    "posts"            : "index"
    "entities/:entity"          : "profile"
    "entities/:entity/:post_id" : "conversation"

  index: =>
    unless TentStatus.current_entity == TentStatus.domain_entity
      @profile(encodeURIComponent(TentStatus.domain_entity))
      return
    @view = new TentStatus.Views.Posts
    window.view = @view
    @setCurrentAction 'index', =>
      @fetchData 'posts', =>
        { posts: new TentStatus.Paginator( TentStatus.Collections.posts ), loaded: false }
      @fetchData 'followers', =>
        { followers: new TentStatus.Paginator( TentStatus.Collections.followers ), loaded: false }
      @fetchData 'followings', =>
        { followings: new TentStatus.Paginator( TentStatus.Collections.followings ), loaded: false }
      @fetchData 'profile', =>
        { profile: TentStatus.Models.profile, loaded: false }

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
    @setCurrentAction 'profile', =>
      @fetchData 'currentProfile', (callback) =>
        _loadedCalled = 0
        _loaded = (data) =>
          return unless data
          return if _loadedCalled
          _loadedCalled = true

          _profile = new TentStatus.Models.Profile data
          callback({ currentProfile: _profile, loaded: true })

        _following = new TentStatus.Models.Following entity: decodeURIComponent(entity)
        _following.fetch
          url: "#{TentStatus.api_root}/followings?entity=#{entity}"
          success: =>
            return _loaded(false) unless _profile = _following.toJSON()[0]?.profile
            _loaded _.extend({follow_type: 'followings'}, _profile)

        _follower = new TentStatus.Models.Follower entity: decodeURIComponent(entity)
        _follower.fetch
          url: "#{TentStatus.api_root}/followers?entity=#{entity}"
          success: =>
            return _loaded(false) unless _profile = _follower.toJSON()[0]?.profile
            _loaded _.extend({follow_type: 'followers'}, _profile)

        @fetchData 'profile', (profileCallback) =>
          TentStatus.Models.profile.fetch
            success: (profile) =>
              if profile.entity() == decodeURIComponent(entity)
                _loadedCalled = true
                callback({ currentProfile: profile, loaded: true })
              profileCallback({ profile: TentStatus.Models.profile, loaded: true })

      @fetchData 'posts', (callback) =>
        options = { url: "#{TentStatus.api_root}/posts?entity=#{entity}" }
        _posts = new TentStatus.Paginator( new TentStatus.Collections.Posts, options )
        callback({ posts: _posts, loaded: false })

      @fetchData 'followers', =>
        { followers: new TentStatus.Paginator( TentStatus.Collections.followers ), loaded: false }
      @fetchData 'followings', =>
        { followings: new TentStatus.Paginator( TentStatus.Collections.followings ), loaded: false }

