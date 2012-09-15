class StatusApp.Views.Followings extends StatusApp.View
  templateName: 'followings'
  partialNames: ['_following']

  dependentRenderAttributes: ['followings', 'groups']

  initialize: ->
    @container = StatusApp.Views.container
    super
    @on 'ready', @initAutoPaginate

  context: =>
    followings: _.map(@followings.toArray(), (following) => _.extend following.toJSON(), {
      name: following.name()
      avatar: following.avatar()
      groups: _.map(@groups.toArray(), (group) -> _.extend group.toJSON(), {
        selected: following.get('groups')?.indexOf(group.id) != -1
      })
    })

  initAutoPaginate: =>
    ($ window).off 'scroll.followings'
    ($ window).on 'scroll.followings', (e)=>
      height = $(document).height() - $(window).height()
      delta = height - window.scrollY
      if delta < 200
        @followings?.nextPage() unless @followings.onLastPage
