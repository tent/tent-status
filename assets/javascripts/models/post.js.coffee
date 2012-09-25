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
      @set 'profile', profile
      return

    if @get('following_id')
      new HTTP 'GET', "#{TentStatus.config.tent_api_root}/followings/#{@get('following_id')}", null, (following, xhr) =>
        return unless xhr.status == 200
        profile = new TentStatus.Models.Profile following.profile
        @set 'profile', profile
        TentStatus.Cache.set cache_key, profile

    else if TentStatus.config.current_entity.hostname == (new HTTP.URI @get('entity')).hostname
      if TentStatus.Models.profile.get('id')
        @set 'profile', TentStatus.Models.profile
        TentStatus.Cache.set cache_key, profile
      else
        TentStatus.Models.profile.fetch
          success: =>
            @set 'profile', TentStatus.Models.profile
            TentStatus.Cache.set cache_key, profile
    else if TentStatus.config.domain_entity.hostname == (new HTTP.URI @get('entity')).hostname
      profile = new TentStatus.Models.Profile
      profile.fetch
        success: =>
          @set 'profile', profile
          TentStatus.Cache.set cache_key, profile
    else if TentStatus.Helpers.isEntityOnTentHostDomain(@get 'entity')
      new HTTP 'GET', "#{@get('entity') + TentStatus.config.tent_host_domain_tent_api_path}/profile", null, (profile, xhr) =>
        return unless xhr.status == 200
        profile = new TentStatus.Models.Profile profile
        @set 'profile', profile
        TentStatus.Cache.set cache_key, profile

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

  isRepost: =>
    !!(@get('type') || '').match(/repost/)

  postMentions: =>
    @post_mentions ?= _.select @get('mentions') || [], (m) => m.entity && m.post

  entity: =>
    return TentStatus.Models.profile if TentStatus.Models.profile.entity() == @get('entity')
    (TentStatus.Collections.followings.find (following) => following.get('entity') == @get('entity')) ||
    (TentStatus.Collections.followers.find (follower) => follower.get('entity') == @get('entity'))

  name: =>
    @entity()?.name() || @get('entity')

  hasName: =>
    !!(@entity()?.hasName())

  avatar: =>
    @entity()?.avatar()

  validate: (attrs) =>
    errors = []

    if attrs.text and attrs.text.match /^[\s\r]*$/
      errors.push { text: 'Status must not be empty' }

    if attrs.text and attrs.text.length > 140
      errors.push { text: 'Status must be no more than 140 characters' }

    return errors if errors.length
    null
