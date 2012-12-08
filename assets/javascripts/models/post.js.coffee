TentStatus.Models.Post = class PostModel extends TentStatus.Model
  @model_name: 'post'

  @middleware: [
    new HTTP.Middleware.MacAuth(TentStatus.config.current_user.auth_details),
    new HTTP.Middleware.SerializeJSON
    new HTTP.Middleware.TentJSONHeader
  ]
  @url: TentStatus.config.tent_api_root + '/posts'
  @create: (data, options = {}) ->
    options.url ?= @url
    options.middleware ?= @middleware

    new HTTP 'POST', options.url.toString(), data, (res, xhr) =>
      unless xhr.status == 200
        @trigger('create:failed', res, xhr)
        options.error?(res, xhr)
        return

      post = new @(res)
      @trigger('create:success', post, xhr)
      options.success?(post, xhr)
    , options.middleware

  @validate: (attrs, options = {}) ->
    errors = []

    if (attrs.content?.text and attrs.content.text.match /^[\s\r\t]*$/) || (options.validate_empty and attrs.content?.text == "")
      errors.push { text: 'Status must not be empty' }

    if attrs.content?.text and attrs.content.text.length > TentStatus.config.MAX_LENGTH
      errors.push { text: "Status must be no more than #{TentStatus.config.MAX_LENGTH} characters" }

    return errors if errors.length
    null

  isRepost: =>
    !!(@get('type') || '').match(/repost/)

  postMentions: =>
    @post_mentions ?= _.select @get('mentions') || [], (m) => m.entity && m.post

  replyToEntities: (options = {}) =>
    _entities = []
    for m in [{ entity: @get('entity') }].concat(@get('mentions'))
      continue unless m && m.entity
      continue if TentStatus.Helpers.isCurrentUserEntity(m.entity)
      _entity = m.entity
      _entity = TentStatus.Helpers.minimalEntity(_entity) if options.trim
      _entities.push(_entity) if _entities.indexOf(_entity) == -1
    _entities

