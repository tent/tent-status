class Profile extends Backbone.Model
  model: 'profile'
  url: "#{TentStatus.config.tent_api_root}/profile"

  initialize: ->
    if entity = @entity()
      TentStatus.Cache.set "profile:#{entity}", @toJSON(), {saveToLocalStorage: true}

  core_profile: =>
    @get('https://tent.io/types/info/core/v0.1.0')

  basic_profile: =>
    @get('https://tent.io/types/info/basic/v0.1.0')

  entity: =>
    @core_profile()?['entity']

  bio: =>
    @basic_profile()?['bio']

  name: =>
    @basic_profile()?['name'] || TentStatus.Helpers.formatUrl(@core_profile()?['entity'] || '')

  hasName: =>
    !!(@basic_profile()?['name'])

  avatar: =>
    TentStatus.Helpers.sanitizeAvatarUrl(@basic_profile()?['avatar_url']) || TentStatus.config.default_avatar

TentStatus.Models.profile = new Profile

class TentStatus.Models.Profile extends Profile
  url: => "#{TentStatus.config.current_tent_api_root}/profile"

  @fetchEntityProfile: (entity, callback) =>
    cache_key = "profile:#{entity}"

    TentStatus.Cache.on "change:#{cache_key}", (profile) =>
      callback(profile) if profile

    TentStatus.Cache.get cache_key, (profile) =>
      return callback(profile) if profile

      if TentStatus.config.current_entity?.hostname == (new HTTP.URI entity).hostname
        if TentStatus.Models.profile.get('id')
          profile = TentStatus.Models.profile.toJSON()
          callback(profile)
          TentStatus.Cache.set cache_key, profile
        else
          TentStatus.Models.profile.fetch
            success: (profile) =>
              profile = profile.toJSON()
              callback(profile)
              TentStatus.Cache.set cache_key, profile
            error: =>
              callback()

      else if TentStatus.config.domain_entity.hostname == (new HTTP.URI entity).hostname
        profile = new TentStatus.Models.Profile
        profile.fetch
          success: (profile) =>
            profile = profile.toJSON()
            callback(profile)
            TentStatus.Cache.set cache_key, profile
          error: =>
            callback()

      else if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
        new HTTP 'GET', "#{entity + TentStatus.config.tent_host_domain_tent_api_path}/profile", null, (profile, xhr) =>
          return callback() unless xhr.status == 200
          return callback() unless profile
          callback(profile)
          TentStatus.Cache.set cache_key, profile
      else
        new HTTP 'GET', "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent entity}/profile", null, (profile, xhr) =>
          return callback() unless xhr.status == 200
          return callback() unless profile
          callback(profile)
          TentStatus.Cache.set cache_key, profile

