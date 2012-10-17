class TentStatus.Models.Post extends Backbone.Model
  model: 'post'
  url: => "#{TentStatus.config.tent_api_root}/posts#{ if @id then "/#{@id}" else ''}"

  initialize: ->
    if @get 'parent'
      @initParentBindings(@get 'parent')
    @on 'change:parent', @initParentBindings

    TentStatus.Cache.set "post:#{@get 'id'}", @

    TentStatus.Reposted.on "change", @get('entity'), @get('id'), (is_reposted) =>
      @set('parent', null) if is_reposted == false
      @set('disable_repost', is_reposted)

    @getProfile()

  initParentBindings: (parent) =>
    if profile = @get('profile')
      parent.trigger 'change:repost:profile', profile
    @on 'change:profile', =>
      profile = @get('profile')
      parent.trigger 'change:repost:profile', profile

  getProfile: =>
    return if @isNew()
    cache_key = "profile:#{@get 'entity'}"

    TentStatus.Cache.on cache_key, (profile) =>
      @set 'profile', profile

    if profile = TentStatus.Cache.get cache_key
      @set 'profile', new TentStatus.Models.Profile(profile)
      return

    if @get('following_id')
      new HTTP 'GET', "#{TentStatus.config.tent_api_root}/followings/#{@get('following_id')}", null, (following, xhr) =>
        return unless xhr.status == 200
        profile = new TentStatus.Models.Profile following.profile
        @set 'profile', profile
        TentStatus.Cache.set cache_key, profile

    else if TentStatus.config.current_entity?.hostname == (new HTTP.URI @get('entity')).hostname
      if TentStatus.Models.profile.get('id')
        @set 'profile', TentStatus.Models.profile
        TentStatus.Cache.set cache_key, profile.toJSON()
      else
        TentStatus.Models.profile.fetch
          success: =>
            @set 'profile', TentStatus.Models.profile
            TentStatus.Cache.set cache_key, profile.toJSON()
    else if TentStatus.config.domain_entity.hostname == (new HTTP.URI @get('entity')).hostname
      profile = new TentStatus.Models.Profile
      profile.fetch
        success: =>
          @set 'profile', profile
          TentStatus.Cache.set cache_key, profile.toJSON()
    else if TentStatus.Helpers.isEntityOnTentHostDomain(@get 'entity')
      new HTTP 'GET', "#{@get('entity') + TentStatus.config.tent_host_domain_tent_api_path}/profile", null, (profile, xhr) =>
        return unless xhr.status == 200
        profile = new TentStatus.Models.Profile profile
        @set 'profile', profile
        TentStatus.Cache.set cache_key, profile.toJSON()
    else
      new HTTP 'GET', "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent @get('entity')}/profile", null, (profile, xhr) =>
        return unless xhr.status == 200
        profile = new TentStatus.Models.Profile profile
        @set 'profile', profile
        TentStatus.Cache.set cache_key, profile.toJSON()

  fetchRepost: =>
    return @get('repost') if @get('repost')
    repost_entity = @get('content')?.entity
    repost_id = @get('content')?.id
    return unless repost_entity and repost_id

    if repost = TentStatus.Cache.get "post:#{repost_id}"
      repost.set 'parent', @
      repost.getProfile()
      @set 'repost', repost
      return

    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent repost_entity}/#{repost_id}", null, (repost, xhr) =>
      return unless xhr.status == 200
      repost.parent = @
      repost = new TentStatus.Models.Post repost
      @set 'repost', repost

    new HTTP 'GET', "#{repost_entity + TentStatus.config.tent_host_domain_tent_api_path}/posts/#{repost_id}", null, (repost, xhr) =>
      return unless xhr.status == 200
      return if @get('repost')
      repost.parent = @
      repost = new TentStatus.Models.Post repost
      @set 'repost', repost

  fetchParents: (callback) =>
    return callback() unless @postMentions().length
    num_fetches = @postMentions().length
    posts = new TentStatus.Collections.Posts
    fetch_complete = (post, xhr) =>
      num_fetches -= 1
      if xhr.status == 200
        posts.push new TentStatus.Models.Post(post)

      callback(posts) if num_fetches == 0

    for m in @postMentions()
      do (m) =>
        entity = m.entity
        post_id = m.post

        url = "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent entity}/#{post_id}"
        params = null

        if TentStatus.config.tent_host_api_root
          hosted_url = "#{TentStatus.config.tent_host_api_root}/posts/#{post_id}"
          hosted_params = {
            entity: entity
          }

        getPostViaProxy = =>
          new HTTP 'GET', "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent entity}/posts/#{post_id}", null, fetch_complete

        if post = TentStatus.Cache.get("post:#{entity}:#{post_id}")
          fetch_complete post, {status:200}
        else
          new HTTP 'GET', url, params, (post, xhr) =>
            if xhr.status != 200
              if TentStatus.config.tent_host_api_root
                new HTTP 'GET', hosted_url, hosted_params, (post, xhr) =>
                  return getPostViaProxy() unless xhr.status == 200
                  fetch_complete(arguments...)
              else
                getPostViaProxy()
            else
              fetch_complete(arguments...)

  fetchChildren: (callback, params={}) =>
    url = "#{TentStatus.config.tent_api_root}/posts"
    params = _.extend {
      limit: TentStatus.config.PER_PAGE
      mentioned_post: @get('id')
      post_types: TentStatus.config.post_types
    }, params

    fetch_complete = (posts, xhr) =>
      return callback() unless xhr.status == 200
      posts = new TentStatus.Collections.Posts posts
      callback(posts)

    if TentStatus.config.tent_host_api_root
      hosted_url = "#{TentStatus.config.tent_host_api_root}/posts"
      hosted_params = _.extend {
        mentioned_entity: @get('entity')
      }, params

    new HTTP 'GET', url, params, (posts, xhr) =>
      if TentStatus.config.tent_host_api_root && (xhr.status != 200 || !posts.length)
        new HTTP 'GET', hosted_url, hosted_params, fetch_complete
      else
        fetch_complete(arguments...)

  isRepost: =>
    !!(@get('type') || '').match(/repost/)

  postMentions: =>
    @post_mentions ?= _.select @get('mentions') || [], (m) => m.entity && m.post

  entity: =>
    return TentStatus.Models.profile if TentStatus.Models.profile.entity() == @get('entity')
    (TentStatus.Collections.followings.find (following) => following.get('entity') == @get('entity')) ||
    (TentStatus.Collections.followers.find (follower) => follower.get('entity') == @get('entity'))

  name: =>
    @entity()?.name() || TentStatus.Helpers.formatUrlWithPath(@get('entity'))

  hasName: =>
    !!(@entity()?.hasName())

  avatar: =>
    @entity()?.avatar()

  validate: (attrs) =>
    errors = []

    if attrs.content?.text and attrs.content.text.match /^[\s\r]*$/
      errors.push { text: 'Status must not be empty' }

    if attrs.content?.text and attrs.content.text.length > TentStatus.config.MAX_LENGTH
      errors.push { text: "Status must be no more than #{TentStatus.config.MAX_LENGTH} characters" }

    return errors if errors.length
    null
