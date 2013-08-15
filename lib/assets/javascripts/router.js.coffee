#= require_self
#= require_tree ./routers

TentStatus.Routers.default = new class DefaultRotuer extends Marbles.Router
  routes: {
    "*" : "notFound"
  }

  actions_titles: {
    notFound : "Not Found"
  }

  notFound: =>
    TentStatus.setPageTitle @actions_titles.notFound
    new Marbles.Views.NotFound container: Marbles.Views.container

