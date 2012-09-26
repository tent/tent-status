class TentStatus.Models.Following extends Backbone.Model
  model: 'following'
  url: => "#{TentStatus.config.tent_api_root}/followings#{ if @id then "/#{@id}" else '' }"

  parse: (attrs) ->
    if attrs.profile
      @set('profile', new TentStatus.Models.Profile attrs.profile)
      delete attrs.profile
    attrs

  initialize: ->
    if profile = TentStatus.Cache.get("profile:#{@get 'entity'}")
      @set 'profile', profile
    @on 'sync', @updateProfile

    @fetchProfile()

  fetchProfile: =>
    TentStatus.Models.Post::getProfile.apply(@)

  name: =>
    @get('profile')?.name?()

  hasName: =>
    @get('profile')?.hasName?()

  avatar: =>
    @get('profile')?.avatar?()
