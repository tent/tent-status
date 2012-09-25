TentStatus.Routers.followings = new class FollowingsRouter extends TentStatus.Router
  routerKey: 'followings'

  routes:
    "followings" : "index"

  index: =>
    if TentStatus.guest_authenticated || !TentStatus.authenticated
      TentStatus.setPageTitle ''
    else
      TentStatus.setPageTitle 'You are following'
    @view = new TentStatus.Views.Followings
