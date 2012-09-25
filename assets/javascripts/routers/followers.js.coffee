TentStatus.Routers.followers = new class Followers extends TentStatus.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    if TentStatus.guest_authenticated || !TentStatus.authenticated
      TentStatus.setPageTitle 'Followers'
    else
      TentStatus.setPageTitle 'Your followers'
    @view = new TentStatus.Views.Followers
