class TentStatus.Views.Conversation extends TentStatus.View
  templateName: 'conversation'
  partialNames: ['_post_inner', '_post', '_reply_form']
  view_name: 'conversation'

  dependentRenderAttributes: ['post']

  initialize: (options = {}) ->
    @post_id = options.post_id
    @entity = (new HTTP.URI options.entity).toStringWithoutSchemePort()
    @container = TentStatus.Views.container
    super

    @on 'ready', @initPostViews

    @on 'change:post', @render
    @on 'change:parent_post', @render
    @on 'change:posts', @render
    @getPost()

  getPost: =>
    url = if TentStatus.config.domain_entity.assertEqual(@entity)
      "#{TentStatus.config.current_tent_api_root}/posts/#{@post_id}"
    else
      "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent @entity}/#{@post_id}"
    params = {
      post_types: TentStatus.config.post_types
    }

    if TentStatus.config.tent_host_api_root
      hosted_url = "#{TentStatus.config.tent_host_api_root}/posts/#{@post_id}"
      hosted_params = _.extend {
        entity: @entity
      }, params

    getPostViaProxy = =>
      new HTTP 'GET', "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent @entity}/posts/#{@post_id}", null, @getPostComplete

    TentStatus.trigger 'loading:start'
    new HTTP 'GET', url, params, (post, xhr) =>
      if xhr.status != 200
        if TentStatus.config.tent_host_api_root
          new HTTP 'GET', hosted_url, hosted_params, (post, xhr) =>
            return getPostViaProxy() unless xhr.status == 200
            @getPostComplete(arguments...)
        else
          getPostViaProxy()
      else
        @getPostComplete(arguments...)

  getPostComplete: (post, xhr) =>
    TentStatus.trigger 'loading:complete'
    return @render404() if xhr.status == 404
    return unless xhr.status == 200
    post = new TentStatus.Models.Post post
    post.on 'change:profile', => @render()
    @set 'post', post

    @getParentPost()
    @getChildPosts()

  getParentPost: =>
    return unless @post.postMentions().length

    entity = @post.postMentions()[0].entity
    post_id = @post.postMentions()[0].post

    url = "#{TentStatus.config.tent_api_root}/posts/#{encodeURIComponent entity}/#{post_id}"
    params = null

    if TentStatus.config.tent_host_api_root
      hosted_url = "#{TentStatus.config.tent_host_api_root}/posts/#{post_id}"
      hosted_params = {
        entity: entity
      }

    if post = TentStatus.Cache.get("post:#{post_id}")
      @set 'parent_post', post
    else
      TentStatus.trigger 'loading:start'
      new HTTP 'GET', url, params, (post, xhr) =>
        if xhr.status != 200 && TentStatus.config.tent_host_api_root
          new HTTP 'GET', hosted_url, hosted_params, @getParentPostComplete
        else
          @getParentPostComplete(arguments...)

  getParentPostComplete: (post, xhr) =>
    TentStatus.trigger 'loading:complete'
    return unless xhr.status == 200
    return unless post
    post = new TentStatus.Models.Post post
    @set 'parent_post', post

  getChildPosts: =>
    url = "#{TentStatus.config.tent_api_root}/posts"
    params = {
      limit: TentStatus.config.PER_PAGE
      mentioned_post: @post_id
      post_types: TentStatus.config.post_types
    }

    if TentStatus.config.tent_host_api_root
      hosted_url = "#{TentStatus.config.tent_host_api_root}/posts"
      hosted_params = _.extend {
        mentioned_entity: @entity
      }, params

      TentStatus.trigger 'loading:start'
      new HTTP 'GET', hosted_url, hosted_params, @getChildPostsComplete

    TentStatus.trigger 'loading:start'
    new HTTP 'GET', url, params, @getChildPostsComplete

  getChildPostsComplete: (posts_attributes, xhr) =>
    TentStatus.trigger 'loading:complete'
    return unless xhr.status == 200

    posts = @posts
    if posts
      _.each posts_attributes, (post_attributes) =>
        return if posts.find (p) -> p.get('id') == post_attributes.id
        posts.push new TentStatus.Models.Post post_attributes
      posts = new TentStatus.Collections.Posts posts.sortBy( (p) -> p.published_at * -1 )
    else
      posts = new TentStatus.Collections.Posts posts_attributes
    @set 'posts', posts

  context: =>
    post: TentStatus.Views.Post::context(@post)
    parent_post: TentStatus.Views.Post::context(@parent_post) if @parent_post
    posts: _.map( @posts?.toArray() || [], (p) -> TentStatus.Views.Post::context(p))

  initPostViews: =>
    _.each ($ 'li.post', @container.$el), (el) =>
      post_id = ($ el).attr('data-id')
      posts = [@post, @parent_post].concat(@get('posts')?.toArray() || []).
                      concat(@get('parent_posts')?.toArray() || [])
      post = _.find posts, (p) => p?.get('id') == post_id
      view = new TentStatus.Views.Post el: el, post: post, parentView: @
      view.trigger 'ready'

