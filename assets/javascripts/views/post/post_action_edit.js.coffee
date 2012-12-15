TentStatus.Views.PostActionEdit = class PostActionEditView extends TentStatus.Views.PostAction
  @view_name: 'post_action_edit'

  performAction: =>
    @editPostView()

  editPostView: =>
    return view if @edit_post_view_cid && (view = TentStatus.Views.EditPost.find(@edit_post_view_cid))
    view = new TentStatus.Views.EditPost parent_view: @parent_view
    @edit_post_view_cid = view.cid
    view

