StatusApp.Routers.followings = new class FollowingsRouter extends StatusApp.Router
  routerKey: 'followings'

  routes:
    "followings" : "index"

  index: =>
    return if StatusApp.guest_authenticated || !StatusApp.authenticated
    @view = new StatusApp.Views.Followings
    @setCurrentAction 'index', =>
      @fetchData 'groups', =>
        { groups: new StatusApp.Paginator( StatusApp.Collections.groups ), loaded: false }
      @fetchData 'followings', =>
        { followings: new StatusApp.Paginator( StatusApp.Collections.followings ), loaded: false }
