TentStatus.Views.SinglePost = class SinglePostView extends TentStatus.View
  @template_name: 'single_post'
  @partial_names: ['_post'].concat(TentStatus.Views.Post.partial_names)
  @view_name: 'single_post'

  constructor: (options = {}) ->
    @container = TentStatus.Views.container
    super

    TentStatus.Models.Post.fetch {entity: options.entity, id: options.id},
      error: =>
      success: (post) =>
        @post_cid = post
        @render(@context(post))

  post: =>
    TentStatus.Models.Post.find(cid: @post_cid)

  context: (post = @post()) =>
    TentStatus.Views.Post::context(post)
