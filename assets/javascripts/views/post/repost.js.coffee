TentStatus.Views.Repost = class RepostView extends TentStatus.Views.Post
  @template_name: '_repost'
  @partial_names: ['_post_inner', '_post_inner_actions']
  @view_name: 'repost'

  constructor: ->
    super

    parent_post = @parentPost()

    TentStatus.Models.Post.find { id: parent_post.get('content.id'), entity: parent_post.get('content.entity') }, {
      success: (post) =>
        @post_cid = post.cid
        @render(@context(post))

      error: (res, xhr) =>
        console.log 'Repost:fetch:failed', res
    }

  parentPost: =>
    TentStatus.Models.Post.instances.all[@parent_view.post_cid]

  post: =>
    TentStatus.Models.Post.instances.all[@post_cid]

  context: (post) =>
    _.extend super, {
      has_parent: true
    }
