class TentStatus.Views.ReplyPostForm extends TentStatus.Views.NewPostForm
  templateName: '_reply_form'
  is_reply_form: true

  initialize: (options = {}) ->
    @postsFeedView = options.parentView.parentView
    @is_reply_form = true

    super

    ## reply fields
    @replyToPostId = ($ '[name=mentions_post_id]', @$el).val()
    @replyToEntity = ($ '[name=mentions_post_entity]', @$el).val()

    @$form = @$el
    @$textarea = ($ 'textarea', @$form)
    @html = @$form.html()

    @$container = @$form.parent()
    @is_repost = @$container.hasClass('repost-reply-container')

    @is_hidden = @$container.hasClass('hide')
    @hide_text = 'Cancel'

    @_initialized = true
    @init()

  init: =>
    return unless @_initialized is true
    @$form.html(@html)

    super

  getReplyButton: =>
    key = if @is_repost then 'reply_repost' else 'reply'
    @parentView.$buttons[key]

  toggle: =>
    if @is_hidden
      @show()
    else
      @hide()

  focusAfterText: =>
    pos = @$textarea.val().length
    input_selection = new TentStatus.Helpers.InputSelection @$textarea.get(0)
    input_selection.setSelectionRange(pos, pos)

  show: =>
    @is_hidden = false
    @$container.removeClass('hide')
    @once 'ready', @hide
    @focusAfterText()
    if $button = @getReplyButton()
      $text = $('.text', $button)
      @show_text ?= $text.text()
      $text.text @hide_text

  hide: =>
    @is_hidden = true
    @$container.addClass('hide')
    if $button = @getReplyButton()
      $text = $('.text', $button)
      $text.text @show_text

  buildMentions: (data) =>
    data = super
    if @replyToPostId and @replyToEntity
      data.mentions ||= []
      existing = false
      for m in data.mentions
        if m.entity == @replyToEntity && !m.post
          m.post = @replyToPostId
          existing = true
          break
      unless existing
        data.mentions.push { entity: @replyToEntity, post: @replyToPostId }
    data

  context: =>
    data = {
      max_chars: TentStatus.config.MAX_LENGTH
    }

    post = @parentView.post
    return data unless post

    post_data = if @is_repost
      repost = @parentView.post.get('repost')
      @parentView.repostContext(post, repost)
    else
      @parentView.context(post)

    _.extend({}, data, post_data)

  render: =>
    @trigger 'ready'

