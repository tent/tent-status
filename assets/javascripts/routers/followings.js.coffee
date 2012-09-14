StatusApp.Routers.followings = new class FollowingsRouter extends StatusApp.Router
  routerKey: 'followings'

  routes:
    "followings" : "index"

  index: =>
    @view = new StatusApp.Views.Followings
    @setCurrentAction 'index', =>
      @fetchData 'groups', =>
        { groups: StatusApp.Collections.groups, loaded: false }
      @fetchData 'followings', =>
        { followings: StatusApp.Collections.followings, loaded: false }
