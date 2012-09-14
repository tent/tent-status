class Profile extends Backbone.Model
  model: 'profile'
  url: => "#{StatusApp.api_root}/profile"

  core_profile: =>
    @get('https://tent.io/types/info/core/v0.1.0')

  basic_profile: =>
    @get('https://tent.io/types/info/basic/v0.1.0')

  entity: =>
    @core_profile()?['entity']

  name: =>
    @basic_profile()?['name'] || @core_profile()?['entity']

  avatar: =>
    @basic_profile()?['avatar_url']

StatusApp.Models.profile = new Profile

class StatusApp.Models.Profile extends Profile
  url: => "#{StatusApp.api_root}/#{@get('follow_type')}/#{@get('id')}/profile"

