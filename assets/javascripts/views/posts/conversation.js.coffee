class TentStatus.Views.Conversation extends TentStatus.View
  templateName: 'conversation'
  partialNames: ['_post_inner', '_post', '_reply_form', 'conversation_parent_posts', 'conversation_child_posts']
  view_name: 'conversation'

  dependentRenderAttributes: ['post']

  initialize: (options = {}) ->
    @post_id = options.post_id
    @entity = (new HTTP.URI options.entity).toStringWithoutSchemePort()
    @container = TentStatus.Views.container
    super

    @on 'ready', @initPostViews

    @once 'change:post', => @post.on 'repost:fetch:failed', @render404
    @once 'change:post', @render
    @once 'change:parent_posts', @renderParentPosts
    @once 'change:posts', @renderChildPosts
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
    @set 'post', post

    @getParentPost()
    @getChildPosts()

  getParentPost: =>
    TentStatus.trigger 'loading:start'
    @post.fetchParents (posts) =>
      TentStatus.trigger 'loading:complete'
      @set 'parent_posts', posts

  getChildPosts: =>
    TentStatus.trigger 'loading:start'
    @post.fetchChildren (posts) =>
      TentStatus.trigger 'loading:complete'
      @set 'posts', posts

  context: =>
    post: TentStatus.Views.Post::context(@post)
    parent_posts: (_.map (@parent_posts?.toArray() || []), (p) => if p then TentStatus.Views.Post::context(p))
    posts: _.map( @posts?.toArray() || [], (p) -> TentStatus.Views.Post::context(p))

  renderParentPosts: =>
    html = @partials['conversation_parent_posts'].render(@context(), @partials)
    $el = $(html)
    @container.$el.prepend($el)
    @initPostViews($el)

  renderChildPosts: =>
    html = @partials['conversation_child_posts'].render(@context(), @partials)
    $el = $(html)
    @container.$el.append($el)
    @initPostViews($el)

  initPostViews: ($el = @container.$el) =>
    _.each ($ 'li.post', $el), (el) =>
      post_id = ($ el).attr('data-id')
      posts = [@post, @parent_post].concat(@get('posts')?.toArray() || []).
                      concat(@get('parent_posts')?.toArray() || [])
      post = _.find posts, (p) => p?.get('id') == post_id
      view = new TentStatus.Views.Post el: el, post: post, parentView: @
      view.trigger 'ready'

