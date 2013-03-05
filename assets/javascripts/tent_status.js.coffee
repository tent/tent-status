#= require_tree ./core_ext
#= require moment
#= require lowdash
#= require marbles
#= require object
#= require setImmediate
#= require string_score
#= require pluralize
#= require http
#= require http/middleware
#= require http/client
#= require ./textarea_cursor_position
#= require ./cache
#= require ./config
#= require_self
#= require ./fetch_interval
#= require http/tent_client
#= require ./model
#= require_tree ./models
#= require ./collection
#= require_tree ./collections
#= require hogan
#= require_tree ./templates
#= require_tree ./helpers
#= require ./view
#= require_tree ./views
#= require_tree ./routers

_.extend TentStatus, Marbles.Events, {
  Models: {}
  Collections: {}
  Routers: {}
  Helpers: {}

  setPageTitle: (options={}) ->
    @current_title ?= {}
    options.page += " -" if options.page
    [prefix, page] = [options.prefix, options.page || @current_title.page]

    prefix = null if page != @current_title.page && @current_title.page

    @current_title.prefix = prefix
    @current_title.page = page

    title = []
    for part in [prefix, page, @config.BASE_TITLE]
      continue unless part
      title.push part
    title = title.join(" ")
    document.title = title

  run: ->
    return if Marbles.history.started

    @showLoadingIndicator()
    @once 'ready', @hideLoadingIndicator

    @on 'loading:start', @showLoadingIndicator
    @on 'loading:stop',  @hideLoadingIndicator

    Marbles.history.start(@config.history_options)

    Marbles.DOM.on window, 'scroll', (e) => @trigger 'window:scroll', e
    Marbles.DOM.on window, 'resize', (e) => @trigger 'window:resize', e

    @ready = true
    @trigger 'ready'

    # Added by Tommi Kaikkonen. This hides and shows the app menu
    # by clicking the menu link when viewport is narrow
    Marbles.DOM.on Marbles.DOM.querySelector('.js-menu-switch'), 'click', (e) =>
      navListElement =  Marbles.DOM.querySelector('.app-nav-list')
      if Marbles.DOM.querySelector('.app-nav-list.show')
        Marbles.DOM.removeClass navListElement, 'show'
      else
        Marbles.DOM.addClass navListElement, 'show'


  showLoadingIndicator: ->
    @_num_running_requests ?= 0
    @_num_running_requests += 1
    Marbles.Views.loading_indicator.show() if @_num_running_requests == 1

  hideLoadingIndicator: ->
    @_num_running_requests ?= 1
    @_num_running_requests -= 1
    Marbles.Views.loading_indicator.hide() if @_num_running_requests == 0

  redirectToGlobalFeed: =>
    return unless TentStatus.config.app_domain
    Marbles.history.navigate('/global', {trigger:true})
}
