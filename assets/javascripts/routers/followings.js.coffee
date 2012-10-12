TentStatus.Routers.followings = new class FollowingsRouter extends TentStatus.Router
  routerKey: 'followings'

  routes:
    "followings" : "index"
    ":entity/followings" : "index"

  index: (entity = TentStatus.config.domain_entity) =>
    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()

    if !entity.isURI
      entity = new HTTP.URI decodeURIComponent(entity)

    if TentStatus.guest_authenticated || !TentStatus.authenticated
      TentStatus.setPageTitle "#{TentStatus.Helpers.formatUrl entity.toStringWithoutSchemePort()} - Followings"
    else
      TentStatus.setPageTitle 'Following'
    @view = new TentStatus.Views.Followings entity: entity

