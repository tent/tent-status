class TentStatus.Views.ReplyPostForm extends TentStatus.Views.NewPostForm
  templateName: '_reply_form'

  initialize: (options = {}) ->
    @postsFeedView = options.parentView.parentView

    super

    ## reply fields
    @replyToPostId = ($ '[name=mentions_post_id]', @$el).val()
    @replyToEntity = ($ '[name=mentions_post_entity]', @$el).val()

    @$form = @$el

    @on 'ready', => @parentView.$reply_container.hide()

  buildMentions: (data) =>
    data = super
    if @replyToPostId and @replyToEntity
      data.mentions ||= []
      data.mentions.push { entity: @replyToEntity, post: @replyToPostId }
    data

  context: => @parentView.context()
