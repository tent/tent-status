TentStatus.Cursors = _.extend {}, Backbone.Events, {
  set: (name, post_entity, post_id, callback) ->
    return callback?() unless TentStatus.config.current_entity
    TentStatus.getCurrentProfile (profile) =>
      type = "https://tent.io/types/info/tent-status/v0.1.0"
      data = profile.get(type) || {}
      data.cursors ||= {}
      data.cursors[name] = {
        post_entity: post_entity
        post_id: post_id
      }
      data.permissions = {
        public: false
      }
      new HTTP 'PUT', "#{TentStatus.config.tent_api_root}/profile/#{encodeURIComponent type}", data, (res, xhr) =>
        return callback?(data.cursors[name], xhr) unless xhr.status == 200
        cursor = res[type]?.cursors?[name]
        callback?(cursor, xhr)
        @trigger "change:#{name}", cursor

  get: (name, callback) ->
    return callback?() unless TentStatus.config.current_entity
    TentStatus.getCurrentProfile (profile) =>
      type = "https://tent.io/types/info/tent-status/v0.1.0"
      data = profile.get(type) || {}
      callback?(data.cursors?[name])

}
