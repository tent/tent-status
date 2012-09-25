TentStatus.Routers.followings = new class FollowingsRouter extends TentStatus.Router
  routerKey: 'followings'

  routes:
    "followings" : "index"

  index: =>
    if TentStatus.guest_authenticated || !TentStatus.authenticated
      TentStatus.setPageTitle "#{TentStatus.Helpers.formatUrl TentStatus.config.domain_entity.toStringWithoutSchemePort()} - Followings"
    else
      TentStatus.setPageTitle 'You are following'
    @view = new TentStatus.Views.Followings
