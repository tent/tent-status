class StatusApp.Models.Post extends Backbone.Model
  model: 'post'
  url: => "#{StatusApp.api_root}/posts#{ if @id then "/#{@id}" else ''}"

  isRepost: =>
    !!@get('type').match(/repost/)

  entity: =>
    return StatusApp.Models.profile if StatusApp.Models.profile.entity() == @get('entity')
    (StatusApp.Collections.followers.find (follower) => follower.get('entity') == @get('entity')) ||
    (StatusApp.Collections.followings.find (following) => following.get('entity') == @get('entity'))

  name: =>
    @entity()?.name() || @get('entity')

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
