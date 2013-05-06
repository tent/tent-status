#= require_tree ./core_ext
#= require moment
#= require pluralize
#= require lodash
#= require marbles
#= require sjcl
#= require tent-client
#= require textarea_cursor_position
#= require ./cache
#= require ./config
#= require_tree ./templates
#= require_self
#= require ./fetch_interval
#= require_tree ./services
#= require_tree ./models
#= require ./collection
#= require_tree ./collections
#= require_tree ./helpers
#= require helpers/extract-urls
#= require_tree ./views
#= require_tree ./routers

Marbles.View.templates = LoDashTemplates

TentStatus.tent_client = new TentClient(
  TentStatus.config.current_user.entity,
  credentials: TentStatus.config.current_user.credentials
  server_meta_post: TentStatus.config.current_user.server_meta_post
)

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

    Marbles.history.start()

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

  redirectToSiteFeed: =>
    return unless TentStatus.config.app_domain
    Marbles.history.navigate('/site-feed', {trigger:true})
}
