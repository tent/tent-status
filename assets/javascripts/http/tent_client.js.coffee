HTTP.TentClient = class HTTPTentClient
  @middleware:
    auth: [
      new HTTP.Middleware.MacAuth(TentStatus.config.current_user.auth_details),
    ]
    tent: [
      new HTTP.Middleware.SerializeJSON
      new HTTP.Middleware.TentJSONHeader
    ]

  @currentEntityClient: (options = {}) ->
    new HTTP.Client _.extend(
      hosts: [TentStatus.config.tent_api_root]
      middleware: [].concat(@middleware.auth, @middleware.tent)
    , options.client_options || {})

  @currentEntityFollowingProxyClient: (following_id, options = {}) ->
    @currentEntityClient _.extend(
      client_options: {
        hosts: [TentStatus.config.tent_api_root + "/followings/#{following_id}"]
      }
    , options.client_options || {})

  @appProxy: (entity, options = {}) ->
    new HTTP.Client _.extend(
      hosts: [TentStatus.config.tent_proxy_root + "/#{encodeURIComponent entity}"]
      middleware: [].concat(@middleware.tent)
    , options.client_options || {})

  @entity_mapping: {}

  @find: (params, callback, options = {}) ->
    return unless (entity = params.entity)

    if client = @entity_mapping[entity]
      callback(client)
      return client

    unless (options.hasOwnProperty('fetch') && !options.fetch)
      @fetch(params, callback, options)

    null

  @fetch: (params, callback, options = {}) ->
    return unless (entity = params.entity)
    entity = entity.toString()

    return if @find(params, callback, _.extend({fetch: false}, options))

    if TentStatus.Helpers.isCurrentEntity(entity)
      client = @currentEntityClient(options)
      @entity_mapping[entity] = client
      return callback(client)

    unless options.skip_following_check
      return @currentEntityClient().get "/followings/#{encodeURIComponent entity}", null, (res, xhr) =>
        return if @find(params, callback, _.extend({fetch: false}, options))
        if xhr.status == 200
          client = @currentEntityFollowingProxyClient(res.id, options)
          @entity_mapping[entity] = client
          callback(client)
        else
          @fetch(params, callback, _.extend(options, {skip_following_check: true}))

    if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
      client = new HTTP.Client {
        hosts: [entity + TentStatus.config.tent_host_domain_tent_api_path]
        middleware: [].concat(@middleware.tent)
      }
      @entity_mapping[entity] = client
      return callback(client)

    if (cid = TentStatus.Models.Profile.entity_mapping[entity]) && (profile = TentStatus.Models.Profile.find(cid: cid, fetch: false))
      if profile.get('servers').length
        client = new HTTP.Client {
          hosts: profile.get('servers')
          middleware: [].concat(@middleware.tent)
        }
        @entity_mapping[entity] = client
        return callback(client)

    client = new HTTP.Client {
      hosts: [TentStatus.config.tent_proxy_root + "/#{encodeURIComponent entity}"]
      middleware: [].concat(@middleware.tent)
    }

    @entity_mapping[entity] = client
    callback(client)

