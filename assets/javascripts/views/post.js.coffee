class StatusApp.Views.Post extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    @buttons = {
      reply: ($ '.navigation .reply', @$el)
    }

    @postId = @$el.attr 'data-id'
    @post = @parentView.posts.get(@postId)

    @buttons.reply.on 'click', (e) =>
      e.preventDefault()
      @showReply()
      false

    @$reply = ($ '.reply-container', @$el).hide()

  showReply: =>
    @$reply.toggle()
