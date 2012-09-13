StatusPro.Routers.followers = new class Followers extends StatusPro.Router
  routerKey: 'followers'

  routes:
    "followers" : "index"

  index: =>
    @view = new StatusPro.Views.Followers
    @setCurrentAction 'index', =>
      @fetchData 'followers', =>
        { followers: StatusPro.Collections.followers, loaded: false }
      @fetchData 'groups', =>
        { groups: StatusPro.Collections.groups, loaded: false }
