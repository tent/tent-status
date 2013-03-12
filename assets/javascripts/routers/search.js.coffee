TentStatus.Routers.search = new class SearchRouter extends Marbles.Router
  routes: {
    "search" : "search"
  }

  actions_titles: {
    'search' : 'Skate Search'
  }

  search: (params) =>
    if !TentStatus.config.search_api_root
      return @navigate('/', {trigger: true, replace: true})

    new Marbles.Views.Search(params: params, container: Marbles.Views.container)
    TentStatus.setPageTitle page: @actions_titles.search
