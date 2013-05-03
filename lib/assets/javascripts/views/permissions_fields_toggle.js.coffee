Marbles.Views.PermissionsFieldsToggle = class PermissionsFieldsToggleView extends TentStatus.View
  @template_name: 'permissions_fields_toggle'
  @view_name: 'permissions_fields_toggle'

  constructor: ->
    super

    @once 'ready', =>
      setImmediate @bindEvents

    @render()

  context: (permissions) =>
    permissions ?= @parentView()?.post()?.get('permissions')
    permissions ?= { public: true }
    _.extend super,
      permissions: permissions

  permissionsFieldsView: =>
    _.last(@parentView()?.childViews('PermissionsFields') || [])

  bindEvents: =>
    permissions_fields_view = @permissionsFieldsView()
    return unless permissions_fields_view

    permissions_fields_view.on 'change:options', =>
      permissions = permissions_fields_view.buildPermissions()
      @render(@context(permissions))

    @text ?= {}
    @text.visibility_toggle = {
      show: Marbles.DOM.attr(@el, 'data-show-text')
      hide: Marbles.DOM.attr(@el, 'data-hide-text')
    }

    Marbles.DOM.on @el, 'click', (e) =>
      e.stopPropagation()
      @toggleVisibility()

  toggleVisibility: =>
    if @visible
      @hide()
    else
      @show()

  hide: =>
    @visible = false
    Marbles.DOM.removeClass(@el, 'visible')
    @permissionsFieldsView()?.hide()

  show: (should_focus = true) =>
    @visible = true
    Marbles.DOM.addClass(@el, 'visible')
    @permissionsFieldsView()?.show()

