_.extend TentStatus.Helpers,
  route: (route_name, params = {}) ->
    switch route_name
      when 'subscribers'
        if params.entity == TentStatus.config.current_user.entity
          @fullPath('/subscribers')
        else
          @fullPath('/' + encodeURIComponent(params.entity) + '/subscribers')
      when 'subscriptions'
        if params.entity == TentStatus.config.current_user.entity
          @fullPath('/subscriptions')
        else
          @fullPath('/' + encodeURIComponent(params.entity) + '/subscriptions')
      when 'profile'
        if params.entity == TentStatus.config.current_user.entity
          @fullPath('/profile')
        else
          @fullPath('/' + encodeURIComponent(params.entity) + '/profile')

  fullPath: (path) ->
    (TentStatus.config.PATH_PREFIX || '').replace(/\/$/, '') + path
