TentStatus.Models.Profile = class ProfileModel extends TentStatus.Model
  @model_name: 'profile'

  @middleware:
    auth: [
      new HTTP.Middleware.MacAuth(TentStatus.config.current_user.auth_details),
    ]
    tent: [
      new HTTP.Middleware.SerializeJSON
      new HTTP.Middleware.TentJSONHeader
    ]

  @entity_mapping: {}

  @fetch: (params = {}, options = {}) ->
    return unless (entity = params.entity)

    # TODO: Add caching (just name and avatar)

    if (cid = @entity_mapping[entity])
      profile = @find(cid: cid)
      options.success?(profile)
      return

    auth_middleware = []
    if TentStatus.Helpers.isDomainEntity(entity)
      api_root = TentStatus.config.tent_api_root
      auth_middleware = @middleware.auth
    else if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
      api_root = entity + TentStatus.config.tent_host_domain_tent_api_path
    else
      api_root = "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent entity}"

    new HTTP 'GET', api_root + '/profile', null, (res, xhr) =>
      if xhr.status != 200 || !res
        @trigger('fetch:failed', entity, res, xhr)
        options.error?(res, xhr)
        return

      if (cid = @entity_mapping[entity])
        profile = @find(cid: cid)
      else
        profile = new @(res)
        @entity_mapping[entity] = profile.cid

      @trigger('fetch:success', entity, profile, xhr)
      options.success?(profile, xhr)
    , auth_middleware.concat(@middleware.tent)

  parseAttributes: (attributes) =>
    core_profile = attributes[TentStatus.config.CORE_PROFILE_TYPE]
    basic_profile = attributes[TentStatus.config.BASIC_PROFILE_TYPE]
    tent_status_profile = attributes[TentStatus.config.TENT_STATUS_PROFILE_TYPE]

    attributes = {
      entity: core_profile?.entity
      servers: core_profile?.servers
      name: basic_profile?.name
      avatar: basic_profile?.avatar_url
      bio: basic_profile?.bio
    }
    attributes[TentStatus.config.TENT_STATUS_PROFILE_TYPE] = tent_status_profile if tent_status_profile

    super(attributes)

  hasName: =>
    !!@get('name')

