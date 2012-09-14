StatusApp.Routers.followers = new class Followers extends StatusApp.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    @view = new StatusApp.Views.Followers
    @setCurrentAction 'index', =>
      @fetchData 'followers', =>
        { followers: StatusApp.Collections.followers, loaded: false }
      @fetchData 'groups', =>
        { groups: StatusApp.Collections.groups, loaded: false }
