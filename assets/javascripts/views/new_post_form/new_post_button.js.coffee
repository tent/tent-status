TentStatus.Views.new_post_button = new class NewPostButton extends TentStatus.View
  initialize: ->
    @setElement document.getElementById('new_post_button')

    @popdown = document.getElementById('new_post_popdown')
    @$popdown = $(@popdown)

    @$main_nav = $('#main-nav')
    @$arrow = $('.arrow', @$popdown)

    @is_visible = false

    @container = { $el: @$popdown, el: @popdown }

    super

    @on 'ready', @initNewPostFormViewBindings
    @trigger 'ready'

    @$el.on 'click', (e) =>
      e.preventDefault()
      @toggle()
      false

    $('body').off('click.new_post_button').on 'click.new_post_button', (e) =>
      is_in_container = !!(_.find $(e.target).parents(), (el) => el == @popdown)
      @hide() unless is_in_container

    @calibrate()

    $(window).off('resize.new_post_button').on 'resize.new_post_button', @calibrate

  initNewPostFormViewBindings: =>
    @new_post_form = @child_views.NewPostForm?[0]
    return unless @new_post_form

    @new_post_form.on 'submit:success', @hide

  postsFeedView: =>
    TentStatus.Views.posts_feed_view

  toggle: =>
    if @is_visible
      @hide()
    else
      @show()

  show: =>
    @is_visible = true
    @$popdown.show()
    @new_post_form.$textarea.focus()

  hide: =>
    @is_visible = false
    @$popdown.hide()

  calibrate: =>
    clearTimeout @_calibrate_timeout
    setTimeout @_calibrate, 100

  _calibrate: =>
    offset_left = @$el.offset().left
    container_width = @$main_nav.width()
    popdown_width = @$popdown.width()
    button_width = @$el.width()
    left = (container_width - popdown_width) - offset_left
    left -= button_width / 2
    left = 0 unless left < 0
    @$popdown.css
      left: left

    arrow_width = @$arrow.width()
    arrow_left = Math.abs(left) + arrow_width + (button_width / 2)

    @$arrow.css
      left: arrow_left

