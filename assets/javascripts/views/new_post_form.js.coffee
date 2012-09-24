class TentStatus.Views.NewPostForm extends TentStatus.View
  templateName: '_new_post_form'

  initialize: (options = {}) ->
    @parentView = options.parentView

    super

    @on 'ready', @init
    @render()

  init: =>
    @$errors = ($ '.alert-error', @$el).first().hide()

    @$post_btn = ($ 'input[type=submit]', @$el)

    @$form = ($ 'form', @$el)
    @$form.off('submit.post').on 'submit.post', @submit
    @$post_btn.off('click.post').on 'click.post', @submit

    ## form validation and character limit counter
    @$textarea = ($ 'textarea', @$el)
    @$charLimit = ($ '.char-limit', @$el).first()
    @charLimit = parseInt(@$charLimit.text())
    @$textarea.on 'keyup', =>
      clearTimeout @_validateTimeout
      @_validateTimeout = setTimeout @validate, 300
      @updateCharCounter()
      null
    @updateCharCounter()

    ## cmd/ctr enter == submit
    @$textarea.off('keydown.keysubmit').on 'keydown.keysubmit', (e) =>
      if (e.metaKey || e.ctrlKey) && e.keyCode == 13
        e.preventDefault()
        @submit()
        false
      else
        true

    ## permissions
    @$publicCheckbox = ($ '[name=public]', @$el)
    @$permissions = ($ 'select[name=permissions]', @$el)
    @$permissions.chosen
      no_results_text: 'No matching entities or groups'

    # disable public checkbox when permissions are added
    @$permissions.change @checkPublicEnabled

    ## mentions
    @$mentionsSelect = ($ 'select[name=mentions]', @$el)
    @$mentionsSelect.chosen
      no_results_text: 'No matching entities'

    ## licenses
    @$licensesSelect = ($ 'select[name=licenses]', @$el)
    @$licensesSelect.chosen
      no_results_text: 'No matching licenses'

    ## advanced options toggle
    @$advancedOptions = ($ '.advanced-options', @$el).hide()
    @$advancedOptionsToggle = ($ '.advanced-options-toggle', @$el)
    @$advancedOptionsToggle.on 'click', (e) =>
      e.preventDefault()
      @$advancedOptions.toggle()
      false

  checkPublicEnabled: =>
    if @$permissions.val() == null
      @enablePublic()
    else
      @disablePublic()

  enablePublic: =>
    @$publicCheckbox.removeAttr('disabled')

  disablePublic: =>
    @$publicCheckbox.removeAttr('checked')
    @$publicCheckbox.attr('disabled', 'disabled')

  disableWith: (text) =>
    @frozen = true
    @post_btn_text = @$post_btn.val()
    @$post_btn.val(text)
    @$post_btn.attr 'disabled', 'disabled'

  enable: =>
    @frozen = false
    @$post_btn.val(@post_btn_text)
    @$post_btn.removeAttr('disabled')

  submit: (e) =>
    e.preventDefault() if e
    data = @getData()
    return false unless @validate data

    @disableWith 'Posting...'
    new HTTP 'POST', "#{TentStatus.config.tent_api_root}/posts", data, (post, xhr) =>
      return @enable() unless xhr.status == 200
      post = new TentStatus.Models.Post post
      @postsFeedView ?= @parentView.postsFeedView?()
      @postsFeedView?.posts.unshift post
      container = @postsFeedView.$el
      TentStatus.Views.Post.insertNewPost(post, container, @postsFeedView)
      @render()
    false

  buildPermissions: (data) =>
    data.permissions = {
      public: true
    }
    data

  buildMentions: (data) =>
    mentions = _.compact (_.map _.flatten(Array data.mentions), (entity) ->
      return unless entity
      { entity: entity }
    )
    delete data.mentions

    for entity in (data.text?.match(/\^(\S+)/g) || [])
      entity = entity.replace(/^\^/, '')
      entity = entity.replace(/^/, 'https://') unless entity.match(/^https?/)
      mentions.push { entity: entity }

    data.mentions = mentions if mentions.length
    data

  buildLicenses: (data) =>
    data.licenses = _.flatten(Array data.licenses) if data.licenses
    data

  buildDataObject: (serializedArray) =>
    data = {}
    for i in serializedArray
      if data[i.name]
        if data[i.name].push
          data[i.name].push i.value
        else
          data[i.name] = [data[i.name], i.value]
      else
        data[i.name] = i.value

    data = @buildLicenses(@buildMentions(@buildPermissions(data)))
    text = data.text
    delete data.text
    _.extend data,
      type: 'https://tent.io/types/post/status/v0.1.0'
      content:
        text: text

  getData: =>
    @buildDataObject @$form.serializeArray()

  validate: (data = @getData()) =>
    post = new TentStatus.Models.Post data
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
    return if @frozen
    charCount = @$textarea.val()?.length
    delta = @charLimit - charCount
    if delta < 0
      @$post_btn.attr 'disabled', 'disabled'
      @$charLimit.addClass 'alert-error'
    else
      if delta == @charLimit
        @$post_btn.attr 'disabled', 'disabled'
      else
        @$post_btn.removeAttr 'disabled'
      @$charLimit.removeClass 'alert-error'
    @$charLimit.text delta

  context: =>
    {}

  render: =>
    return unless html = super
    el = ($ html)
    @$el.replaceWith(el)
    @setElement el
    @trigger 'ready'
    html

