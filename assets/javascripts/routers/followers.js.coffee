TentStatus.Routers.followers = new class Followers extends TentStatus.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    return if TentStatus.guest_authenticated || !TentStatus.authenticated
    @view = new TentStatus.Views.Followers
    @setCurrentAction 'index', =>
      @fetchData 'followers', =>
        { followers: new TentStatus.Paginator( TentStatus.Collections.followers ), loaded: false }
      @fetchData 'groups', =>
        { groups: new TentStatus.Paginator( TentStatus.Collections.groups ), loaded: false }
