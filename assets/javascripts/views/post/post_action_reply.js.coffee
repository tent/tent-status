Marbles.Views.PostActionReply = class PostActionReplyView extends Marbles.Views.PostAction
  @view_name: 'post_action_reply'

  performAction: =>
    post_reply_view_cid = @parent_view._child_views.PostReplyForm[0]
    post_reply_view = TentStatus.View.instances.all[post_reply_view_cid]
    post_reply_view.toggle()

