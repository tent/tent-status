# Custom View Class extending Backbone.View
#
# Sample View Class:
# class StatusPro.Views.DashboardArticles extends StatusPro.View
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

class StatusPro.View extends Backbone.View
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
    @container ||= StatusPro.Views.container

    unless @container
      StatusPro.devWarning @, "You need to define @container View"

    # fetch main template
    if @templateName
      StatusPro.fetchTemplate @templateName, (@template) =>
        @trigger 'template:load'

    # load all partials listed in partialNames
    if @partialNames
      @partials = {}
      for p in @partialNames
        do (p) =>
          StatusPro.fetchTemplate p, (template) =>
            name = @getPartialName(p)
            @partials[name] = template
            @trigger "partials:#{name}:load"

    @on 'ready', @bindViews
    @on 'ready', @bindEvents

  loadMore: (key) =>
    @get(key)?.nextPage()

  bindEvents: =>
    _.each $('.btn.load-more', @container?.el), (el) =>
      viewKey = $(el).attr('data-key')

      $(el).hide() if @get(viewKey)?.onLastPage
      @get(viewKey)?.on 'fetch:start',   => $(el).hide()
      @get(viewKey)?.on 'fetch:success', => $(el).show() unless @get(viewKey)?.onLastPage

      $(el).off().on 'click', (=> @loadMore viewKey)

  bindViews: =>
    _.each $('[data-view]', @container?.el), (el) =>
      viewClassName = $(el).attr 'data-view'
      if viewClass = StatusPro.Views[viewClassName]
        view = new viewClass el: el, parentView: @
      else
        StatusPro.devWarning @, "StatusPro.Views.#{viewClassName} is not defined!"
        console.log el

  getPartialName: (path) =>
    path.replace(/.+\/_(.+)$/, "$1")

  # called before fetching data in the router
  empty: =>
    @container?.render("")

  context: =>
    StatusPro.devWarning @, "You need to override context in your view class!"
    {}

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
        unless @get(key)
          @once "change:#{key}", => @render(arguments...)
          return false

    html = @template.render(@context(), @partials)
    @container?.render(html)
    @trigger 'ready'
    true

