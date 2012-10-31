# Custom View Class extending Backbone.View
#
# Sample View Class:
# class TentStatus.Views.DashboardArticles extends TentStatus.View
#   templateName: 'foo/bar'
#
#   # e.g. dashboard/_header is available as @partials.header
#   partialNames: ['baz/_header']
#
#   # wait for attributes to be set with @set before rendering
#   dependentRenderAttributes: ['foos']
# 
#   initialize: (options) ->
#     super
#
#     # Custom view initialization, e.g.:
#     @on 'ready', @bindEvents
# 
#   # setup context object passed to template
#   # context is the data object for the view
#   # See (mustache syntax): http://mustache.github.com/mustache.5.html
#   # See (hogan example): http://twitter.github.com/hogan.js/
#   context: =>
#     foos: foos.toJSON()
#
#   render: =>
#     # do anything special here
#
#     super

class TentStatus.View extends Backbone.View
  # simpler version of @set and @get than given with Backbone.Model
  # @set sets the key directly on the View instance
  # it's used to pass data from the router to the view
  set: (key, val) =>
    @[key] = val
    @trigger "change:#{key}"

  # see render method in above sample
  get: (key) =>
    @[key]

  # fetch template and partials
  # once loaded @template will hold the compiled hogan template specified with @templateName
  # and @partials will hold all compiled templates defined in @partialNames
  initialize: (options) ->
    # fetch main template
    if @templateName
      TentStatus.fetchTemplate @templateName, (@template) =>
        @trigger 'template:load'

    # load all partials listed in partialNames
    if @partialNames
      @partialNames.push '_404'

      @partials = {}
      for p in @partialNames
        do (p) =>
          TentStatus.fetchTemplate p, (template) =>
            name = @getPartialName(p)
            @partials[name] = template
            @trigger "partials:#{name}:load"

    @on 'ready', @bindViews

  bindViews: (data_binding='data-view') =>
    @child_views = {}
    _.each $("[#{data_binding}]", (@container?.el || @$el)), (el) =>
      viewClassName = $(el).attr data_binding
      if viewClass = TentStatus.Views[viewClassName]
        view = new viewClass el: el, parentView: @
        @child_views[viewClassName] ?= []
        @child_views[viewClassName].push view
        @trigger "init:#{viewClassName}", view
      else
        TentStatus.devWarning @, "TentStatus.Views.#{viewClassName} is not defined!"
        console?.log el

  getPartialName: (path) =>
    path.replace(/.+\/_(.+)$/, "$1")

  # called before fetching data in the router
  empty: =>
    @container?.render("")

  context: =>
    authenticated: TentStatus.authenticated
    guest_authenticated: TentStatus.guest_authenticated

  # wait for @template and @partials to load
  # then render @template with @context and @partials
  # and insert html into @container.el
  render: =>
    # wait for template to be loaded
    if @templateName
      unless @template
        @once 'template:load', => @render(arguments...)
        return false

    # wait for partials to be loaded
    if @partialNames
      for p in @partialNames
        name = @getPartialName(p)
        unless @partials[name]
          @once "partials:#{name}:load", => @render(arguments...)
          return false

    # wait for data to be loaded
    if @dependentRenderAttributes
      for key in @dependentRenderAttributes
        if @get(key) == null
          @once "change:#{key}", => @render(arguments...)
          return false

    context = _.extend {
      authenticated: TentStatus.authenticated
      guest_authenticated: TentStatus.guest_authenticated
    }, @context()

    html = @template.render(context, @partials)
    if @container
      @container.render(html)
      @trigger 'ready'
      true
    else
      html

  render404: =>
    return false unless template = @partials['_404']
    html = template.render(@notFoundContext?() || {})
    if @container
      @container.render(html)
      @trigger '404:ready'
      true
    else
      html

