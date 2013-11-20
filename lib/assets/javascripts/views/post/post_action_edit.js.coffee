Marbles.Views.PostActionEdit = class PostActionEditView extends Marbles.Views.PostAction
  @view_name: 'post_action_edit'

  performAction: =>
    post_view = @postView()
    edit_view = @editPostView()

    edit_view.render()

  editPostView: =>
    view = Marbles.Views.EditPost.find(@edit_view_cid) if @edit_view_cid
    return view if view

    post_view = @postView()
    view = new Marbles.Views.EditPost(el: post_view.el, parent_view: @postView())
    @edit_view_cid = view.cid

    view

