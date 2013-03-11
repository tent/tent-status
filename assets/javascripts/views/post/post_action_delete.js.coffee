Marbles.Views.PostActionDelete = class PostActionDeleteView extends Marbles.Views.PostAction
  @view_name: 'post_action_delete'

  postView: => @parentView()

  post: => @postView()?.post()

  showErrors: (error) =>
    alert(_.map(error, (e) -> e.text).join("\n"))

  performAction: =>
    @delete()

  delete: =>
    post = @post()
    post.delete(
      error: (res, xhr) =>
        @enable()
        @showErrors([{ text: "Error: #{JSON.parse(xhr.responseText)?.error}" }])

      success: (post, xhr) =>
        @detachPost()
    )

  detachPost: =>
    post_view = @postView()
    Marbles.DOM.removeNode(post_view.el)
    post_view.detach()

