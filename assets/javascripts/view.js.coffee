TentStatus.View = class View
  @instances: {
    all: {}
  }
  @_id_counter: 0
  @view_name: '_default'

  @find: (cid) ->
    @instances.all[cid]

  @getTemplate: (template_path) ->
    HoganTemplates[template_path]

  @detach: (cid) ->
    delete @instances[cid]

  detach: =>
    @constructor.detach(@cid)

  constructor: (options = {}) ->
    @generateCid()
    @trackInstance()
    @initTemplates()

    for k in ['el', 'parent_view', 'container']
      @set(k, options[k]) if options[k]

    @on 'ready', @bindViews

  generateCid: =>
    @cid = "#{@constructor.view_name}_#{@constructor._id_counter++}"

  trackInstance: =>
    @constructor.instances.all[@cid] = @
    @constructor.instances[@constructor.view_name] ?= []
    @constructor.instances[@constructor.view_name].push @cid

  initTemplates: =>
    @constructor.template ?= @constructor.getTemplate(@constructor.template_name) if @constructor.template_name
    if !@constructor.partials && @constructor.partial_names
      @constructor.partials = {}
      for name in @constructor.partial_names
        @constructor.partials[name] = @constructor.getTemplate(name)

  bindViews: (options = {}) =>
    unless options.keep_existing
      # detach old child views
      for class_name, cids of (@_child_views || {})
        for cid in cids
          @constructor.instances[cid]?.detach()

      @_child_views = {}

    _.each DOM.querySelectorAll('[data-view]', (@container?.el || @el)), (el) =>
      view_class_name = DOM.attr(el, 'data-view')

      if viewClass = TentStatus.Views[view_class_name]
        return if el.view_cid && viewClass.instances.all[el.view_cid]

        view = new viewClass el: el, parent_view: @
        @_child_views[view_class_name] ?= []
        @_child_views[view_class_name].push view.cid
        el.view_cid = view.cid
        @trigger "init:#{view_class_name}", view
      else
        console.warn "TentStatus.Views.#{view_class_name} is not defined!"

  childViews: (view_class_name) =>
    _.map @_child_views[view_class_name], (cid) => @constructor.find(cid)

  context: =>
    config: TentStatus.config

  renderHTML: (context = @context()) =>
    @constructor.template.render(context, @constructor.partials)

  render: (context = @context()) =>
    html = @renderHTML(context)

    if @container?.el
      @el = document.createElement('div')
      @el.innerHTML = html
      DOM.replaceChildren(@container.el, @el)
    else
      @el.innerHTML = html

    @trigger 'ready'

_.extend View::, Backbone.Events, TentStatus.Accessors

