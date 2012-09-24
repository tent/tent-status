class Profile extends Backbone.Model
  model: 'profile'
  url: "#{TentStatus.config.tent_api_root}/profile"

  initialize: ->
    if entity = @entity()
      TentStatus.Cache.set "profile:#{entity}", @

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
    @basic_profile()?['avatar_url']

TentStatus.Models.profile = new Profile

class TentStatus.Models.Profile extends Profile
  url: => "#{TentStatus.config.current_tent_api_root}/profile"

