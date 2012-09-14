class StatusApp.Models.Following extends Backbone.Model
  model: 'following'
  url: => "#{StatusApp.api_root}/followings#{ if @id then "/#{@id}" else ''}"

  initialize: ->
    @on 'sync', @updateProfile
    @updateProfile()

  updateProfile: =>
    profile = @get('profile')
    core_profile = {}
    basic_profile = {}
    for type, content of profile
      basic_profile = content if type.match(/types\/info\/basic/)
      core_profile = content if type.match(/types\/info\/core/)
    @set 'core_profile', core_profile
    @set 'basic_profile', basic_profile

  name: =>
    @get('basic_profile')['name'] || @get('core_profile')['entity']

  avatar: =>
    @get('basic_profile')['avatar_url']

