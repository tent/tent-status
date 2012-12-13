class Profile extends Backbone.Model
  model: 'profile'
  url: "#{TentStatus.config.tent_api_root}/profile"

  parse: (res, xhr) =>
    core_profile = res[TentStatus.config.CORE_PROFILE_TYPE]
    basic_profile = res[TentStatus.config.BASIC_PROFILE_TYPE]
    tent_status_profile = res[TentStatus.config.TENT_STATUS_PROFILE_TYPE]

    data = {
      entity: core_profile?.entity
      servers: core_profile?.servers
      name: basic_profile?.name
      avatar: basic_profile?.avatar_url
      website_url: basic_profile?.website_url
      bio: basic_profile?.bio
    }
    data[TentStatus.config.TENT_STATUS_PROFILE_TYPE] = tent_status_profile if tent_status_profile

    data

  initialize: ->
    if entity = @entity()
      TentStatus.Cache.set "profile:#{entity}", @toJSON(), {saveToLocalStorage: true}

  core_profile: =>
    entity: @get('entity')
    servers: @get('servers')

  basic_profile: =>
    name: @get('name')
    avatar_url: @get('avatar')
    bio: @get('bio')

  toJSON: =>
    profile = {}
    profile[TentStatus.config.CORE_PROFILE_TYPE] = @core_profile()
    profile[TentStatus.config.BASIC_PROFILE_TYPE] = @basic_profile()
    if tent_status_profile = @get(TentStatus.config.TENT_STATUS_PROFILE_TYPE)
      profile[TentStatus.config.TENT_STATUS_PROFILE_TYPE] = tent_status_profile
    profile

  entity: =>
    @get 'entity'

  bio: =>
    @get 'bio'

  name: =>
    @get('name') || TentStatus.Helpers.formatUrl(@get('entity') || '')

  hasName: =>
    !!@get('name')

  avatar: =>
    @get('avatar') || TentStatus.config.default_avatar

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
        else
          TentStatus.Models.profile.fetch
            success: (profile) =>
              profile = profile.toJSON()
              callback(profile)
            error: =>
              callback()

      else if TentStatus.config.domain_entity.hostname == (new HTTP.URI entity).hostname
        profile = new TentStatus.Models.Profile
        profile.fetch
          success: (profile) =>
            profile = profile.toJSON()
            callback(profile)
          error: =>
            callback()

      else if TentStatus.Helpers.isEntityOnTentHostDomain(entity)
        new HTTP 'GET', "#{entity + TentStatus.config.tent_host_domain_tent_api_path}/profile", null, (profile, xhr) =>
          return callback() unless xhr.status == 200
          return callback() unless profile
          profile = new TentStatus.Models.Profile(profile).toJSON() # filter JSON and save to cache
          callback(profile)
      else
        new HTTP 'GET', "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent entity}/profile", null, (profile, xhr) =>
          return callback() unless xhr.status == 200
          return callback() unless profile
          profile = new TentStatus.Models.Profile(profile).toJSON() # filter JSON and save to cache
          callback(profile)

