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

    # TODO: Add caching

    if (cid = @entity_mapping[entity])
      profile = @find(cid: cid)
      options.success?(profile)
      return

    unless options.client
      return HTTP.TentClient.find entity: entity, (client) =>
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

