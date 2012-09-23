class TentStatus.Views.Conversation extends TentStatus.View
  templateName: 'conversation'
  partialNames: ['_post_inner', '_post']

  dependentRenderAttributes: ['post']

  initialize: (options = {}) ->
    @post_id = options.post_id
    @entity = options.entity
    @container = TentStatus.Views.container
    super

    @on 'ready', @initPostViews

    @on 'change:post', @render
    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/#{@post_id}", null, (post, xhr) =>
      return unless xhr.status == 200
      post = new TentStatus.Models.Post post
      post.on 'change:profile', => @render()
      @set 'post', post

      @on 'change:child_posts', @render
      new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts", {
        limit: TentStatus.config.PER_PAGE
        mentioned_post: @post_id
      }, (posts, xhr) =>
        return unless xhr.status == 200
        since_id = posts[posts.length-1]?.id
        posts = new TentStatus.Collections.Posts posts
        @set 'child_posts', posts

      return unless @post.postMentions().length

      entity = @post.postMentions()[0].entity
      post_id = @post.postMentions()[0].post

      @on 'change:parent_post', @render
      new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent entity}/#{post_id}", null, (post, xhr) =>
        return unless xhr.status == 200
        post = new TentStatus.Models.Post post
        @set 'parent_post', post

  context: =>
    post: TentStatus.Views.Post::context(@post)
    parent_post: TentStatus.Views.Post::context(@parent_post) if @parent_post
    child_posts: _.map( @child_posts?.toArray() || [], (p) -> TentStatus.Views.Post::context(p))

  initPostViews: =>
    _.each ($ 'li.post', @container.$el), (el) =>
      post_id = ($ el).attr('data-id')
      posts = [@post].concat(@get('child_posts')?.toArray() || []).
                      concat(@get('parent_posts')?.toArray() || [])
      post = _.find posts, (p) => p.get('id') == post_id
      view = new TentStatus.Views.Post el: el, post: post, parentView: @
      view.trigger 'ready'
