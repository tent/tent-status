TentStatus.Routers.posts = new class PostsRouter extends Marbles.Router
  routes: {
    "signin" : "signin"
  }

  actions_titles: {
    "signin" : "Sign in"
  }

  signin: (params) =>
    if params.redirect && params.redirect.indexOf('//') != -1 && params.redirect.indexOf('//') == params.redirect.indexOf('/')
      params.redirect = null
    params.redirect ?= TentStatus.config.PATH_PREFIX || '/'

    if TentStatus.config.authenticated
      return Marbles.history.navigate(params.redirect, trigger: true)

    unless TentStatus.config.SIGNIN_URL
      return window.location.href = TentStatus.config.SIGNOUT_REDIRECT_URL

    Marbles.Views.AppNavigationItem.disableAll()

    TentStatus.setPageTitle page: @actions_titles.signin

    new Marbles.Views.Signin container: Marbles.Views.container, redirect_url: params.redirect

