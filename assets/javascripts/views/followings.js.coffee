class StatusApp.Views.Followings extends StatusApp.View
  templateName: 'followings'
  partialNames: ['_following']

  dependentRenderAttributes: ['followings', 'groups']

  initialize: ->
    @container = StatusApp.Views.container
    super

  context: =>
    followings: _.map(@followings.toArray(), (following) => _.extend following.toJSON(), {
      name: following.name()
      avatar: following.avatar()
      groups: _.map(@groups.toArray(), (group) -> _.extend group.toJSON(), {
        selected: following.get('groups')?.indexOf(group.id) != -1
      })
    })
