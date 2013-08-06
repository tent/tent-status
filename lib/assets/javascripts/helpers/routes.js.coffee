_.extend TentStatus.Helpers,
  entityProfileUrl: (entity) ->
    return unless entity
    @route('profile', entity: entity)

  route: (route_name, params = {}) ->
    switch route_name
      when 'subscribers'
        if params.entity == TentStatus.config.meta.content.entity
          @fullPath('/subscribers')
        else
          @fullPath('/' + encodeURIComponent(params.entity) + '/subscribers')
      when 'subscriptions'
        if params.entity == TentStatus.config.meta.content.entity
          @fullPath('/subscriptions')
        else
          @fullPath('/' + encodeURIComponent(params.entity) + '/subscriptions')
      when 'profile'
        if @isAppDomain()
          if params.entity == TentStatus.config.meta.content.entity
            @fullPath("/profile")
          else
            @fullPath("/#{encodeURIComponent params.entity}/profile")
        else
          params.entity
      when 'post'
        if params.entity == TentStatus.config.meta.content.entity
          "/posts/#{encodeURIComponent params.post_id}"
        else
          "/posts/#{encodeURIComponent params.entity}/#{encodeURIComponent params.post_id}"

  fullPath: (path) ->
    (TentStatus.config.PATH_PREFIX || '').replace(/\/$/, '') + path
