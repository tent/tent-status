TentStatus.Routers.search = new class SearchRouter extends Marbles.Router
  routes: {
    "search" : "search"
  }

  actions_titles: {
    'search' : 'Skate Search'
  }

  _initAuthorInfoView: (options = {}) =>
    new Marbles.Views.AuthorInfo _.extend options,
      el: document.getElementById('author-info')

  search: (params) =>
    if TentStatus.Helpers.appDomain() && !TentStatus.Helpers.isAppSubdomain()
      return window.location.href = TentStatus.Helpers.appDomain() + "/search#{Marbles.history.serializeParams(params)}"

    if !TentStatus.config.search_api_root
      return @navigate('/', {trigger: true, replace: true})

    new Marbles.Views.Search(params: params, container: Marbles.Views.container)
    @_initAuthorInfoView()

    TentStatus.setPageTitle page: @actions_titles.search
