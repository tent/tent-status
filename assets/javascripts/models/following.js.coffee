class TentStatus.Models.Following extends Backbone.Model
  model: 'following'
  url: => "#{TentStatus.config.tent_api_root}/followings#{ if @id then "/#{@id}" else '' }"

  initialize: ->
    if profile = TentStatus.Cache.get("profile:#{@get 'entity'}")
      @set 'profile', profile
    else if profile = @get('profile') and entity = @get('entity')
      TentStatus.Cache.set("profile:#{entity}", profile)

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

  hasName: =>
    !!(@get('basic_profile')['name'])

  avatar: =>
    @get('basic_profile')['avatar_url']
