StatusApp.Routers.followers = new class Followers extends StatusApp.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    @view = new StatusApp.Views.Followers
    @setCurrentAction 'index', =>
      @fetchData 'followers', =>
        { followers: new StatusApp.Paginator( StatusApp.Collections.followers ), loaded: false }
      @fetchData 'groups', =>
        { groups: new StatusApp.Paginator( StatusApp.Collections.groups ), loaded: false }
