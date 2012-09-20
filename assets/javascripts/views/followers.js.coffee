class TentStatus.Views.Followers extends TentStatus.View
  templateName: 'followers'
  partialNames: ['_follower']

  dependentRenderAttributes: ['followers', 'groups']

  initialize: ->
    @container = TentStatus.Views.container
    super

    @on 'ready', @initAutoPaginate

  context: =>
    followers: _.map(@followers.toArray(), (follower) => _.extend follower.toJSON(), {
      name: follower.name()
      avatar: follower.avatar()
      groups: _.map(@groups.toArray(), (group) -> _.extend group.toJSON(), {
        selected: follower.get('groups')?.indexOf(group.id) != -1
      })
    })

  initAutoPaginate: =>
    ($ window).off 'scroll.followers'
    ($ window).on 'scroll.followers', (e)=>
      height = $(document).height() - $(window).height()
      delta = height - window.scrollY
      if delta < 200
        @followers?.nextPage() unless @followers.onLastPage
