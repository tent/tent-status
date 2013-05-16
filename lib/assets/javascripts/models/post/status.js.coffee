TentStatus.Models.StatusPost = class StatusPostModel extends TentStatus.Models.Post
  @model_name: 'status_post'
  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.STATUS)

  @validate: (attrs, options = {}) ->
    errors = []

    if (attrs.content?.text and attrs.content.text.match /^[\s\r\t]*$/) || (options.validate_empty and attrs.content?.text == "")
      errors.push { text: 'Status must not be empty' }

    if attrs.content?.text and TentStatus.Helpers.byteLength(attrs.content.text) > TentStatus.config.MAX_STATUS_LENGTH
      errors.push { text: "Status must be no more than #{TentStatus.config.MAX_STATUS_LENGTH} bytes" }

    return errors if errors.length
    null

  fetchReplies: (options = {}) =>
    collection = TentStatus.Collections.StatusReplies.find(entity: @get('entity'), post_id: @get('id'))
    collection ?= new TentStatus.Collections.StatusReplies(entity: @get('entity'), post_id: @get('id'))

    limit = TentStatus.config.CONVERSATION_PER_PAGE

    collection.options.params = {
      mentions: @get('entity') + ' ' + @get('id')
      types: [TentStatus.config.POST_TYPES.STATUS_REPLY]
      limit: limit
    }

    if collection.model_ids.length
      options.success?(collection.models(collection.model_ids.slice(0, limit)))
    else
      collection.fetch null, options

    null

