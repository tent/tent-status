TentStatus.Views.PostActionReply = class PostActionReplyView extends TentStatus.Views.PostAction
  @view_name: 'post_action_reply'

  performAction: =>
    post_reply_view_cid = @parent_view._child_views.PostReplyForm[0]
    post_reply_view = TentStatus.View.instances.all[post_reply_view_cid]
    post_reply_view.toggle()

