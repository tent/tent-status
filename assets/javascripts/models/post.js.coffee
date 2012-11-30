TentStatus.Models.Post = class PostModel extends TentStatus.Model
  @model_name: 'post'

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

