Marbles.Views.ProfileAvatar = class ProfileAvatarView extends Marbles.Views.ProfileComponent
  @template_name: '_profile_avatar'
  @view_name: 'profile_avatar'

  constructor: ->
    super

    @fetch()

