#= require_tree ./core_ext
#= require moment
#= require underscore
#= require backbone
#= require setImmediate
#= require string_score
#= require pluralize
#= require http
#= require http/middleware
#= require http/client
#= require ./textarea_cursor_position
#= require ./events
#= require ./cache
#= require ./config
#= require ./accessors
#= require ./dom
#= require_self
#= require http/tent_client
#= require object
#= require ./model
#= require_tree ./models
#= require ./collection
#= require_tree ./collections
#= require hogan
#= require_tree ./templates
#= require_tree ./helpers
#= require ./view
#= require_tree ./views
#= require ./history
#= require ./router
#= require_tree ./routers

_.extend TentStatus, TentStatus.Events, {
  Views: {}
  Models: {}
  Collections: {}
  Routers: {}
  Helpers: {}

  setPageTitle: (title, options={}) ->
    base_title = @config.BASE_TITLE
    title = title + base_title if title
    title ?= base_title

  run: ->
    return if Backbone.history.started

    @showLoadingIndicator()
    @once 'ready', @hideLoadingIndicator

    @on 'loading:start', @showLoadingIndicator
    @on 'loading:stop',  @hideLoadingIndicator

    Backbone.history.start(@config.history_options)

    DOM.on window, 'scroll', (e) => @trigger 'window:scroll', e
    DOM.on window, 'resize', (e) => @trigger 'window:resize', e

    @ready = true
    @trigger 'ready'

  showLoadingIndicator: ->
    @_num_running_requests ?= 0
    @_num_running_requests += 1
    @Views.loading_indicator.show() if @_num_running_requests == 1

  hideLoadingIndicator: ->
    @_num_running_requests ?= 1
    @_num_running_requests -= 1
    @Views.loading_indicator.hide() if @_num_running_requests == 0

  redirectToGlobalFeed: =>
    return unless TentStatus.config.app_domain
    Backbone.history.navigate('/global', {trigger:true})
}
