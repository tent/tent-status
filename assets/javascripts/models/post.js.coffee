class TentStatus.Models.Post extends Backbone.Model
  model: 'post'
  url: => "#{TentStatus.api_root}/posts#{ if @id then "/#{@id}" else ''}"

  isRepost: =>
    !!(@get('type') || '').match(/repost/)

  fetchRepost: =>
    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/#{@get 'repost_id'}", null, (repost, xhr) =>
      return unless xhr.status == 200
      @set 'repost', new TentStatus.Models.Post repost

  entity: =>
    return TentStatus.Models.profile if TentStatus.Models.profile.entity() == @get('entity')
    (TentStatus.Collections.followings.find (following) => following.get('entity') == @get('entity')) ||
    (TentStatus.Collections.followers.find (follower) => follower.get('entity') == @get('entity'))

  name: =>
    @entity()?.name() || @get('entity')

  hasName: =>
    !!(@entity()?.hasName())

  avatar: =>
    @entity()?.avatar()

  validate: (attrs) =>
    errors = []

    if attrs.text and attrs.text.match /^[\s\r]*$/
      errors.push { text: 'Status must not be empty' }

    if attrs.text and attrs.text.length > 140
      errors.push { text: 'Status must be no more than 140 characters' }

    return errors if errors.length
    null
