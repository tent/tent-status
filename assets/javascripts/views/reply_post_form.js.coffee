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
      data.mentions.push { entity: @replyToEntity, post: @replyToPostId }
    data

  context: =>
    post = @parentView.post
    return {} unless post

    console.log @, @is_repost, post.get('entity'), post

    if @is_repost
      repost = @parentView.post.get('repost')
      @parentView.repostContext(post, repost)
    else
      @parentView.context(post)

  render: =>
    @trigger 'ready'

