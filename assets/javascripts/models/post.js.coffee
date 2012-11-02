class TentStatus.Models.Post extends Backbone.Model
  model: 'post'
  url: => "#{TentStatus.config.tent_api_root}/posts#{ if @id then "/#{@id}" else ''}"

  initialize: ->
    if @get 'parent'
      @initParentBindings(@get 'parent')
    @on 'change:parent', @initParentBindings

    TentStatus.Cache.set "post:#{@get 'id'}", _.extend(@toJSON(), {
      parent: null,
      repost: null,
      profile: null
    })

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
    TentStatus.Models.Profile.fetchEntityProfile @get('entity'), (profile) =>
      return unless profile
      @set 'profile', new TentStatus.Models.Profile(profile)

  fetchRepost: (self = @, level = 1) =>
    return self.get('repost') if self.get('repost')
    return @trigger('repost:fetch:failed') if level >= 3
    repost_entity = self.get('content')?.entity
    repost_id = self.get('content')?.id
    return @trigger('repost:fetch:failed') unless repost_entity and repost_id

    TentStatus.Cache.get "post:#{repost_id}", (repost) =>
      if repost
        repost = new TentStatus.Models.Post repost
        repost.set 'parent', @
        repost.getProfile()
        return @fetchRepost(repost, level + 1) if repost.isRepost()
        @set('repost', repost) unless repost.attributes == @get('repost')?.attributes
      else
        fetchFromTentHost = =>
          new HTTP 'GET', "#{repost_entity + TentStatus.config.tent_host_domain_tent_api_path}/posts/#{repost_id}", null, (repost, xhr) =>
            unless xhr.status == 200
              @trigger 'repost:fetch:failed'
              return
            repost.parent = @
            repost = new TentStatus.Models.Post repost
            return @fetchRepost(repost, level + 1) if repost.isRepost()
            @set('repost', repost) unless repost.attributes == @get('repost')?.attributes

        new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent repost_entity}/#{repost_id}", null, (repost, xhr) =>
          return fetchFromTentHost() unless xhr.status == 200
          repost.parent = @
          repost = new TentStatus.Models.Post repost
          return @fetchRepost(repost, level + 1) if repost.isRepost()
          @set('repost', repost) unless repost.attributes == @get('repost')?.attributes

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

        TentStatus.Cache.get "post:#{entity}:#{post_id}", (post) =>
          if post
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

  validate: (attrs, changes, validate_empty=false) =>
    errors = []

    if (attrs.content?.text and attrs.content.text.match /^[\s\r\t]*$/) || (validate_empty and attrs.content?.text == "")
      errors.push { text: 'Status must not be empty' }

    if attrs.content?.text and attrs.content.text.length > TentStatus.config.MAX_LENGTH
      errors.push { text: "Status must be no more than #{TentStatus.config.MAX_LENGTH} characters" }

    return errors if errors.length
    null

