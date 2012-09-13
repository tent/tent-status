StatusPro.Routers.followings = new class FollowingsRouter extends StatusPro.Router
  routerKey: 'followings'

  routes:
    "followings" : "index"

  index: =>
    @view = new StatusPro.Views.Followings
    @setCurrentAction 'index', =>
      @fetchData 'groups', =>
        { groups: StatusPro.Collections.groups, loaded: false }
      @fetchData 'followings', =>
        { followings: StatusPro.Collections.followings, loaded: false }
