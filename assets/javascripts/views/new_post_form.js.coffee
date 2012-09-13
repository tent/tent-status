class StatusPro.Views.NewPostForm extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @action = "#{StatusPro.api_root}/posts"

    @$errors = ($ '.alert-error', @$el).first().hide()

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
    @$permissible_groups = ($ 'select[name=permissible_groups]', @$el)
    @$permissible_entities = ($ 'select[name=permissible_entities]', @$el)
    @$permissible_groups.chosen
      no_results_text: 'No matching groups'
    @$permissible_entities.chosen
      no_results_text: 'No matching entities'

    # disable public checkbox when permissions are added
    @$permissible_groups.change @checkPublicEnabled
    @$permissible_entities.change @checkPublicEnabled

    ## mentions
    @$mentionsSelect = ($ 'select[name=mentions]', @$el)
    @$mentionsSelect.chosen
      no_results_text: 'No matching entities'

    ## licenses
    @$licensesSelect = ($ 'select[name=licenses]', @$el)
    @$licensesSelect.chosen
      no_results_text: 'No matching licenses'


  checkPublicEnabled: =>
    if @$permissible_groups.val() == null and @$permissible_entities.val() == null
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

    post = new StatusPro.Models.Post data
    post.once 'sync', =>
      StatusPro.Collections.posts.push(post)
      @parentView.set('posts', StatusPro.Collections.posts)
      @parentView.render()
    post.save()
    false

  buildPermissions: (data) =>
    _public = if data['public'] == 'on' then true else false
    _groups = _.inject _.flatten(Array data.permissible_groups), ((memo, groupId) ->
      return memo unless groupId
      memo.push { id: groupId }
      memo
    ), []
    _entities = _.inject _.flatten(Array data.permissible_entities), ((memo, entity) ->
      return memo unless entity
      memo[entity] = true
      memo
    ), {}

    delete data['public']
    delete data.permissible_groups
    delete data.permissible_entities

    data.permissions = {
      public: _public,
      groups: _groups,
      entities: _entities
    }

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
    charCount = @$textarea.val()?.length
    delta = @charLimit - charCount
    if delta < 0
      @$charLimit.addClass 'alert-error'
    else
      @$charLimit.removeClass 'alert-error'
    @$charLimit.text delta

