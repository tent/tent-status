Marbles.Views.PostActionRepost = class PostActionRepostView extends Marbles.Views.PostAction
  @view_name: 'post_action_repost'

  performAction: =>
    post = TentStatus.Models.Post.find(cid: @parentView().post_cid)
    data = {
      permissions:
        public: true
      type: "https://tent.io/types/repost/v0##{(new TentClient.PostType post.get('type')).toStringWithoutFragment()}"
      mentions: [{ entity: post.get('entity'), post: post.get('id') }]
      content:
        entity: post.get('entity')
        post: post.get('id')
    }
    TentStatus.Models.Post.create(data,
      error: (res, xhr) =>
        @enable()
        alert("Error: #{JSON.parse(xhr.responseText)?.error}") # TODO: use a more unobtrusive notification

      success: (post, xhr) =>
        @disable()
    )

  enable: =>
    @disabled = false

  disable: =>
    @disabled = true

