TentStatus.Models.Profile = class ProfileModel extends TentStatus.Model
  @model_name: 'profile'
  @id_mapping_scope: ['entity']

  @entity_mapping: {}

  @fetch: (params = {}, options = {}) ->
    return unless (entity = params.entity)

    # TODO: Add caching

    if (cid = @entity_mapping[entity])
      profile = @find(cid: cid)
      options.success?(profile)
      return

    unless options.client
      return Marbles.HTTP.TentClient.find entity: entity, (client) =>
        @fetch(params, _.extend(options, {client: client}))

    options.client.get '/profile', null, (res, xhr) =>
      if xhr.status != 200 || !res
        @trigger('fetch:failed', entity, res, xhr)
        options.error?(res, xhr)
        return

      if (cid = @entity_mapping[entity])
        profile = @find(cid: cid, fetch: false)
      else
        profile = new @(res)
        @entity_mapping[entity] = profile.cid

      @trigger('fetch:success', entity, profile, xhr)
      options.success?(profile, xhr)

  parseAttributes: (attributes) =>
    core_profile = attributes[TentStatus.config.PROFILE_TYPES.CORE]
    basic_profile = attributes[TentStatus.config.PROFILE_TYPES.BASIC]

    attributes = {
      entity: core_profile?.entity
      servers: core_profile?.servers
      name: basic_profile?.name
      avatar: basic_profile?.avatar_url
      bio: basic_profile?.bio
      website_url: basic_profile?.website_url
    }

    # Use https proxy when available and avatar non-https
    if TentStatus.avatar_proxy_service && attributes.avatar && !attributes.avatar.match(/^https/)
      attributes.avatar = TentStatus.avatar_proxy_service.proxyURL(attributes.avatar)

    super(attributes)

  hasName: =>
    !!@get('name')

