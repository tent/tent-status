TentStatus.Routers.followers = new class Followers extends TentStatus.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    return if TentStatus.guest_authenticated || !TentStatus.authenticated
    TentStatus.setPageTitle 'Your followers'
    @view = new TentStatus.Views.Followers
