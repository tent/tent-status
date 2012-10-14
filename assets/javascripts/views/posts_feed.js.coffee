class TentStatus.Views.PostsFeed extends TentStatus.View
  templateName: 'posts_feed'
  partialNames: ['_reply_form', '_post', '_post_inner']
  view_name: 'posts_feed'

  initialize: (options = {}) ->
    options.posts_params ?= {}
    super

    @on 'change:posts', @render
    @on 'ready', @initPostViews
    @on 'ready', @initAutoPaginate

    TentStatus.Views.posts_feed_view = @

    params = _.extend({
      post_types: TentStatus.config.post_types
      limit: TentStatus.config.PER_PAGE
    }, options.posts_params)

    options.api_root ?= TentStatus.config.tent_api_root
    url = "#{options.api_root}/posts"
    TentStatus.trigger 'loading:start'
    new HTTP 'GET', url, params, (posts, xhr) =>
      TentStatus.trigger 'loading:complete'
      return unless xhr.status == 200
      since_id = _.last(posts)?.id
      since_id_entity = _.last(posts)?.entity
      paginator = new TentStatus.Paginator(new TentStatus.Collections.Posts(posts), { since_id_entity: since_id_entity, sinceId: since_id, url: url, params: params })
      paginator.on 'fetch:success', @appendRender
      @set 'posts', paginator

  context: =>
    posts: (_.map @posts?.toArray() || [], (post) =>
      TentStatus.Views.Post::context(post)
    )

  appendRender: (new_posts) =>
    html = ""
    $last_post = $('.post:last', @$el)
    new_posts = for post in new_posts
      post = new TentStatus.Models.Post post
      html += TentStatus.Views.Post::renderHTML(TentStatus.Views.Post::context(post), @partials)
      post

    @$el.append(html)
    _.each $last_post.nextAll('.post'), (el, index) =>
      view = new TentStatus.Views.Post el: el, post: new_posts[index], parentView: @
      view.trigger 'ready'

  render: =>
    html = super
    @$el.html(html)
    @trigger 'ready'

  initPostViews: =>
    _.each ($ 'li.post', @$el), (el) =>
      post_id = ($ el).attr('data-id')
      post = _.find @posts?.toArray() || [], (p) => p.get('id') == post_id
      view = new TentStatus.Views.Post el: el, post: post, parentView: @
      view.trigger 'ready'

  initAutoPaginate: =>
    ($ window).off('scroll.posts').on 'scroll.posts', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    $last_post = ($ 'li.post:last', @$el)
    last_post_offset_top = $last_post.offset()?.top || 0
    bottom_position = window.scrollY + $(window).height()

    if last_post_offset_top < (bottom_position + 300)
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @posts?.nextPage, 0 unless @posts.onLastPage
