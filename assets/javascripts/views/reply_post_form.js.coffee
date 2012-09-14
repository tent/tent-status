class StatusPro.Views.ReplyPostForm extends StatusPro.Views.NewPostForm
  initialize: (options = {}) ->
    super

    ## reply fields
    @replyToPostId = ($ '[name=mentions_post_id]', @$el).val()
    @replyToEntity = ($ '[name=mentions_post_entity]', @$el).val()

  submit: (e) =>
    e.preventDefault()
    data = @getData()
    return false unless @validate data

    post = new StatusPro.Models.Post data
    post.once 'sync', =>
      @parentView.posts.push(post)
      @parentView.render()
    post.save()
    false

  buildMentions: (data) =>
    data = super
    if @replyToPostId and @replyToEntity
      data.mentions ||= []
      data.mentions.push { entity: @replyToEntity, post: @replyToPostId }
    data

