class StatusPro.Views.NewPostForm extends Backbone.View
  initialize: (options) ->
    @parentView = options.parentView

    @action = "#{StatusPro.api_root}/posts"

    @$errors = ($ '.alert-error', @$el).first().hide()

    @$el.on 'submit', @submit

    @$textarea = ($ 'textarea', @$el)
    @$charLimit = ($ '.char-limit', @$el).first()
    @charLimit = parseInt(@$charLimit.text())
    @$textarea.on 'keyup', =>
      clearTimeout @_validateTimeout
      @_validateTimeout = setTimeout @validate, 300
      @updateCharCounter()
      null
    @updateCharCounter()

  submit: (e) =>
    e.preventDefault()
    data = @getData()
    return false unless @validate data

    post = new StatusPro.Models.Post data
    post.once 'sync', =>
      StatusPro.Collections.posts.push(post)
      @parentView.set('posts', StatusPro.Collections.posts)
      @parentView.render()
    post.save()
    false

  getData: =>
    data = {}
    data[i.name] = i.value for i in @$el.serializeArray()
    data

  validate: (data = @getData()) =>
    post = new StatusPro.Models.Post data
    errors = post.validate(data)
    @$el.find(".error").removeClass('error')
    @$errors.hide()
    @showErrors(errors) if errors
    return !errors

  showErrors: (errors) =>
    error_messages = []
    for err in errors
      for name, msg of err
        $input = @$el.find("[name='#{name}']")
        $input.addClass('error')
        error_messages.push msg
    @$errors.html error_messages.join('<br/>')
    @$errors.show()

  updateCharCounter: =>
    charCount = @$textarea.val().length
    delta = @charLimit - charCount
    if delta < 0
      @$charLimit.addClass 'alert-error'
    else
      @$charLimit.removeClass 'alert-error'
    @$charLimit.text delta

