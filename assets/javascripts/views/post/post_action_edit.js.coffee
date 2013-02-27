Marbles.Views.PostActionEdit = class PostActionEditView extends Marbles.Views.PostAction
  @view_name: 'post_action_edit'

  performAction: =>
    @editPostView()

  editPostView: =>
    return view if @edit_post_view_cid && (view = Marbles.Views.EditPost.find(@edit_post_view_cid))
    view = new Marbles.Views.EditPost parent_view: @parent_view
    @edit_post_view_cid = view.cid
    view

