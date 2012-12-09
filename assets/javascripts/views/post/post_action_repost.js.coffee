TentStatus.Views.PostActionRepost = class PostActionRepostView extends TentStatus.Views.PostAction
  @view_name: 'post_action_repost'

  performAction: =>
    post = TentStatus.Models.Post.find(cid: @parent_view.post_cid)
    data = {
      permissions:
        public: true
      type: 'https://tent.io/types/post/repost/v0.1.0'
      mentions: [{ entity: post.get('entity'), post: post.get('id') }]
      content:
        entity: post.get('entity')
        id: post.get('id')
    }
    TentStatus.Models.Post.create(data,
      error: (res, xhr) =>
        @enable()
        alert("Error: #{JSON.parse(xhr.responseText)?.error}") # TODO: use a more unobtrusive notification

      success: (post, xhr) =>
        @disable()
    )

  enable: =>

  disable: =>

