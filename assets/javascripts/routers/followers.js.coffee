StatusApp.Routers.followers = new class Followers extends StatusApp.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    return if StatusApp.guest_authenticated || !StatusApp.authenticated
    @view = new StatusApp.Views.Followers
    @setCurrentAction 'index', =>
      @fetchData 'followers', =>
        { followers: new StatusApp.Paginator( StatusApp.Collections.followers ), loaded: false }
      @fetchData 'groups', =>
        { groups: new StatusApp.Paginator( StatusApp.Collections.groups ), loaded: false }
