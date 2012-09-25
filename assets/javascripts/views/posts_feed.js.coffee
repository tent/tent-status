class TentStatus.Views.PostsFeed extends TentStatus.View
  templateName: 'posts_feed'
  partialNames: ['_reply_form', '_post', '_post_inner']

  initialize: (options) ->
    options.posts_params ?= {}
    super

    @on 'change:posts', @render
    @on 'ready', @initPostViews
    @on 'ready', @initAutoPaginate

    params = _.extend({
      post_types: TentStatus.config.post_types
      limit: TentStatus.config.PER_PAGE
    }, options.posts_params)

    options.api_root ?= TentStatus.config.tent_api_root
    new HTTP 'GET', "#{options.api_root}/posts", params, (posts, xhr) =>
      return unless xhr.status == 200
      since_id = _.last(posts)?.id
      since_id_entity = _.last(posts)?.entity
      paginator = new TentStatus.Paginator(new TentStatus.Collections.Posts(posts), _.extend({ since_id_entity: since_id_entity, sinceId: since_id }, { params: options.posts_params }))
      paginator.on 'fetch:success', @render
      @set 'posts', paginator

  context: =>
    posts: (_.map @posts?.toArray() || [], (post) =>
      TentStatus.Views.Post::context(post)
    )

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
    height = $(document).height() - $(window).height() - $last_post.offset().top
    delta = height - window.scrollY

    if delta < 600
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @posts?.nextPage, 0 unless @posts.onLastPage
