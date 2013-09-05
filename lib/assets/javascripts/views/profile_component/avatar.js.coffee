Marbles.Views.ProfileAvatar = class ProfileAvatarView extends Marbles.Views.ProfileComponent
  @template_name: '_profile_avatar'
  @view_name: 'profile_avatar'

  constructor: ->
    super

    @on 'ready', @checkImageMortality

    @render()

  checkImageMortality: =>
    img = Marbles.DOM.querySelector('img', @el)
    unless img.complete
      return setTimeout @checkImageMortality, 10

    # Fallback to default avatar if image fails to load
    if img.naturalHeight == 0 && TentStatus.config.DEFAULT_AVATAR_URL
      img.src = TentStatus.config.DEFAULT_AVATAR_URL

