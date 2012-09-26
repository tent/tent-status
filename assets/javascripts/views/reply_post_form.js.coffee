class TentStatus.Views.ReplyPostForm extends TentStatus.Views.NewPostForm
  templateName: '_reply_form'

  initialize: (options = {}) ->
    @postsFeedView = options.parentView.parentView

    super

    ## reply fields
    @replyToPostId = ($ '[name=mentions_post_id]', @$el).val()
    @replyToEntity = ($ '[name=mentions_post_entity]', @$el).val()

    @$form = @$el
    @html = @$form.html()

    @is_repost = @$form.parent().hasClass('repost-reply-container')

    ## this references the wrong instance in render, TODO: debug and fix this issue
    $form = @$form
    html = @html
    @on 'ready', => $form.html(html)
    @on 'ready', => $form.parent().hide()

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
      max_chars: TentStatus.config.max_length
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

