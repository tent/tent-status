TentStatus.Routers.followings = new class FollowingsRouter extends TentStatus.Router
  routerKey: 'followings'

  routes:
    "followings" : "index"

  index: =>
    return if TentStatus.guest_authenticated || !TentStatus.authenticated
    @view = new TentStatus.Views.Followings
    @setCurrentAction 'index', =>
      @fetchData 'groups', =>
        { groups: new TentStatus.Paginator( TentStatus.Collections.groups ), loaded: false }
      @fetchData 'followings', =>
        { followings: new TentStatus.Paginator( TentStatus.Collections.followings ), loaded: false }
