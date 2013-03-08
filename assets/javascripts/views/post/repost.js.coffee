Marbles.Views.Repost = class RepostView extends Marbles.Views.Post
  @template_name: '_repost'
  @partial_names: ['_post_inner', '_post_inner_actions']
  @view_name: 'repost'

  constructor: ->
    super

    @fetchPost()

  parentPost: =>
    TentStatus.Models.Post.instances.all[@parent_view.post_cid]

  conversationView: => @findParentView('conversation')

  fetchPost: (parent_post = @parentPost()) =>
    TentStatus.Models.Post.find { id: parent_post.get('content.id'), entity: parent_post.get('content.entity') }, {
      success: (post) =>
        return @fetchPost(post) if post.isRepost()
        @post_cid = post.cid
        @render(@context(post))

      error: (res, xhr) =>
        @parent_view.hide()
        console.log 'Repost:fetch:failed', res
    }

  post: =>
    TentStatus.Models.Post.instances.all[@post_cid]

  context: (post) =>
    parent_post = @parentPost()
    _.extend super, {
      has_parent: true
      is_conversation_view: !!@conversationView()
      parent:
        cid: parent_post.cid
        formatted:
          entity: TentStatus.Helpers.minimalEntity(parent_post.get('entity'))
    }
