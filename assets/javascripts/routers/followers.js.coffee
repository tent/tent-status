TentStatus.Routers.followers = new class Followers extends TentStatus.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()

    if TentStatus.guest_authenticated || !TentStatus.authenticated
      TentStatus.setPageTitle "#{TentStatus.Helpers.formatUrl TentStatus.config.domain_entity.toStringWithoutSchemePort()} - Followers"
    else
      TentStatus.setPageTitle 'Your followers'
    @view = new TentStatus.Views.Followers
