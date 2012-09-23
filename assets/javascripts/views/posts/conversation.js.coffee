class TentStatus.Views.Conversation extends TentStatus.View
  templateName: 'conversation'

  dependentRenderAttributes: ['post']

  initialize: (options = {}) ->
    @post_id = options.post_id
    @entity = options.entity
    @container = TentStatus.Views.container
    super

    @on 'change:post', @render
    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/#{@post_id}", null, (post, xhr) =>
      return unless xhr.status == 200
      post = new TentStatus.Models.Post post
      @set 'post', post

  context: =>
    post: TentStatus.Views.Post::context(@post)

  render: =>
    html = super
    console.log html, @context()

