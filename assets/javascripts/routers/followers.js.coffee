TentStatus.Routers.followers = new class Followers extends TentStatus.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"
    ":entity/followers" : "index"

  index: (entity = TentStatus.config.domain_entity) =>
    if TentStatus.isAppSubdomain()
      return TentStatus.redirectToGlobalFeed()

    if !entity.isURI
      entity = new HTTP.URI decodeURIComponent(entity)

    guest_authenticated = TentStatus.guest_authenticated || !TentStatus.config.domain_entity.assertEqual(entity)
    if guest_authenticated || !TentStatus.authenticated
      TentStatus.setPageTitle "#{TentStatus.Helpers.formatUrl entity.toStringWithoutSchemePort()} - Followers"
    else
      TentStatus.setPageTitle 'Your followers'
    @view = new TentStatus.Views.Followers entity: entity
