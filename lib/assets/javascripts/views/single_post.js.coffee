Marbles.Views.SinglePost = class SinglePostView extends Marbles.View
  @template_name: 'single_post'
  @partial_names: ['_post'].concat(Marbles.Views.Post.partial_names)
  @view_name: 'single_post'

  constructor: (options = {}) ->
    @container = Marbles.Views.container
    super

    TentStatus.Models.StatusPost.fetch {entity: options.entity, id: options.id},
      error: =>
      success: (post) =>
        @post_cid = post
        @render(@context(post))

  post: =>
    TentStatus.Models.StatusPost.find(cid: @post_cid)

  context: (post = @post()) =>
    Marbles.Views.Post::context(post)
