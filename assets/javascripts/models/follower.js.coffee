class TentStatus.Models.Follower extends Backbone.Model
  model: 'follower'
  url: => "#{TentStatus.config.tent_api_root}/followers#{ if @id then "/#{@id}" else ''}"

  parse: (attrs) ->
    if attrs.profile
      @set('profile', new TentStatus.Models.Profile attrs.profile)
      delete attrs.profile
    attrs

  initialize: ->
    @fetchProfile()

  fetchProfile: =>
    TentStatus.Models.Post::getProfile.apply(@)

  name: =>
    @get('profile')?.name?()

  hasName: =>
    @get('profile')?.hasName?()

  avatar: =>
    @get('profile')?.avatar?()
