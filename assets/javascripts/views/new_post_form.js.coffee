class StatusApp.Views.NewPostForm extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @action = "#{StatusApp.api_root}/posts"

    @$errors = ($ '.alert-error', @$el).first().hide()

    @$post_btn = ($ 'input[type=submit]', @$el)

    @$el.on 'submit', @submit

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

  submit: (e) =>
    e.preventDefault()
    data = @getData()
    return false unless @validate data

    post = new StatusApp.Models.Post data
    post.once 'sync', =>
      StatusApp.Collections.posts.push(post)
      @parentView.set('posts', StatusApp.Collections.posts)
      @parentView.render()
    post.save()
    false

  buildPermissions: (data) =>
    _public = if data['public'] == 'on' then true else false
    permissions = {
      public: _public
    }

    _groups = _.each _.flatten(Array data.permissions), (entityOrGroupId) ->
      return unless entityOrGroupId
      [type, value] = [entityOrGroupId.slice(0,2), entityOrGroupId.slice(2, entityOrGroupId.length)]
      switch type
        when 'g:'
          permissions.groups ||= []
          permissions.groups.push { id: value }
        when 'f:'
          permissions.entities ||= {}
          permissions.entities[value] = true

    delete data['public']
    delete data.permissible_groups
    delete data.permissible_entities

    data.permissions = permissions
    data

  buildMentions: (data) =>
    mentions = _.compact (_.map _.flatten(Array data.mentions), (entity) ->
      return unless entity
      { entity: entity }
    )
    delete data.mentions

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

    @buildLicenses(@buildMentions(@buildPermissions(data)))

  getData: =>
    @buildDataObject @$el.serializeArray()

  validate: (data = @getData()) =>
    post = new StatusApp.Models.Post data
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

