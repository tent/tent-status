TentStatus.Views.Follower = class FollowerView extends TentStatus.View
  @template_name: '_follower'
  @view_name: 'follower'

  constructor: (options = {}) ->
    super

    @follower_cid = DOM.attr(@el, 'data-cid')
    @entity = @follower().get('entity')

  context: (follower) =>
    _.extend super,
      cid: follower.cid

  follower: =>
    TentStatus.Models.Follower.find(cid: @follower_cid)

  profile: =>
    new TentStatus.Object entity: @entity
