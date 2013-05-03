Marbles.Views.Following = class FollowingView extends TentStatus.View
  @template_name: '_following'
  @view_name: 'following'

  constructor: (options = {}) ->
    super

    @following_cid = Marbles.DOM.attr(@el, 'data-cid')
    @entity = @following().get('entity')

  context: (following) =>
    _.extend super,
      cid: following.cid

  following: =>
    TentStatus.Models.Following.find(cid: @following_cid)

  profile: =>
    new Marbles.Object entity: @entity
