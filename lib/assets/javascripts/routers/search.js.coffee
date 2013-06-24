TentStatus.Routers.search = new class SearchRouter extends Marbles.Router
  routes: {
    "search" : "search"
  }

  actions_titles: {
    'search' : 'Skate Search'
  }

  _initMiniProfileView: (options = {}) =>
    new Marbles.Views.MiniProfile _.extend options,
      el: document.getElementById('author-info')

  search: (params) =>
    if !TentStatus.config.services.search_api_root
      return @navigate('/', {trigger: true, replace: true})

    new Marbles.Views.Search(params: params, container: Marbles.Views.container)
    @_initMiniProfileView()

    TentStatus.setPageTitle page: @actions_titles.search
