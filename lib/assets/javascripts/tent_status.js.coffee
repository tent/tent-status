#= require_tree ./core_ext
#= require moment
#= require tent-client
#= require ./config
#= require sjcl
#= require tent-markdown
#= require textarea_cursor_position
#= require_tree ./templates
#= require_self
#= require ./fetch_interval
#= require_tree ./services
#= require_tree ./models
#= require ./collection
#= require ./unified_collection
#= require ./collection_pool
#= require ./unified_collection_pool
#= require_tree ./collections
#= require_tree ./helpers
#= require helpers/extract-urls
#= require_tree ./views
#= require_tree ./routers

Marbles.View.templates = LoDashTemplates

_.extend TentStatus, Marbles.Events, {
  Models: {}
  Collections: {}
  Routers: {}
  Helpers: {}

  setPageTitle: (options={}) ->
    @current_title ?= {}
    options.page += " -" if options.page
    [prefix, page] = [options.prefix, options.page || @current_title.page]

    if @current_title.page && !options.prefix
      prefix = null if page != @current_title.page

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

    Marbles.DOM.on window, 'scroll', (e) => @trigger 'window:scroll', e
    Marbles.DOM.on window, 'resize', (e) => @trigger 'window:resize', e

    # load top level data-view bindings
    _body_view = new Marbles.View el: document.body
    _body_view.trigger('ready')

    Marbles.history.start(root: (TentStatus.config.PATH_PREFIX || '') + '/')

    if !TentStatus.config.authenticated
      Marbles.Views.AppNavigationItem.disableAllExcept('profile')
      Marbles.history.navigate('profile', { trigger: true, replace: true })

    @ready = true
    @trigger 'ready'

  showLoadingIndicator: ->
    @_num_running_requests ?= 0
    @_num_running_requests += 1
    Marbles.Views.loading_indicator.show() if @_num_running_requests == 1

  hideLoadingIndicator: ->
    @_num_running_requests ?= 1
    @_num_running_requests -= 1
    Marbles.Views.loading_indicator.hide() if @_num_running_requests == 0
}

TentStatus.trigger('config:ready') if TentStatus.config_ready

