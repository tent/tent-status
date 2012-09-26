class TentStatus.Views.Conversation extends TentStatus.View
  templateName: 'conversation'
  partialNames: ['_post_inner', '_post', '_reply_form']

  dependentRenderAttributes: ['post']

  initialize: (options = {}) ->
    @post_id = options.post_id
    @entity = options.entity
    @container = TentStatus.Views.container
    super

    @on 'ready', @initPostViews

    @on 'change:post', @render
    url = if TentStatus.config.domain_entity.assertEqual(@entity)
      "#{TentStatus.config.current_tent_api_root}/posts/#{@post_id}"
    else
      "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent @entity}/#{@post_id}"
    params = {
      post_types: TentStatus.config.post_types
    }
    new HTTP 'GET', url, params, (post, xhr) =>
      return @render404() if xhr.status == 404
      return unless xhr.status == 200
      post = new TentStatus.Models.Post post
      post.on 'change:profile', => @render()
      @set 'post', post

      @on 'change:posts', @render
      new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts", _.extend({
        limit: TentStatus.config.PER_PAGE
        mentioned_post: @post_id
      }, params), (posts, xhr) =>
        return @render404() if xhr.status == 404
        return unless xhr.status == 200
        since_id = posts[posts.length-1]?.id
        posts = new TentStatus.Collections.Posts posts
        @set 'posts', posts

      return unless @post.postMentions().length

      entity = @post.postMentions()[0].entity
      post_id = @post.postMentions()[0].post

      if post = TentStatus.Cache.get("post:#{post_id}")
        @set 'parent_post', post
      else
        @on 'change:parent_post', @render
        new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent entity}/#{post_id}", null, (post, xhr) =>
          return @render404() if xhr.status == 404
          return unless xhr.status == 200
          post = new TentStatus.Models.Post post
          @set 'parent_post', post

  context: =>
    post: TentStatus.Views.Post::context(@post)
    parent_post: TentStatus.Views.Post::context(@parent_post) if @parent_post
    posts: _.map( @posts?.toArray() || [], (p) -> TentStatus.Views.Post::context(p))

  initPostViews: =>
    _.each ($ 'li.post', @container.$el), (el) =>
      post_id = ($ el).attr('data-id')
      posts = [@post].concat(@get('posts')?.toArray() || []).
                      concat(@get('parent_posts')?.toArray() || [])
      post = _.find posts, (p) => p.get('id') == post_id
      view = new TentStatus.Views.Post el: el, post: post, parentView: @
      view.trigger 'ready'
