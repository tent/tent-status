class TentStatus.Views.PostsFeed extends TentStatus.View
  templateName: 'posts_feed'
  partialNames: ['_reply_form', '_post', '_post_inner']

  initialize: (options) ->
    super

    @on 'change:posts', @render
    @on 'render', @initPostViews
    @on 'render', @initAutoPaginate

    params = {
      post_types: TentStatus.config.post_types
      limit: TentStatus.config.PER_PAGE
    }

    options.api_root ?= TentStatus.config.tent_api_root
    new HTTP 'GET', "#{options.api_root}/posts", params, (posts, xhr) =>
      return unless xhr.status == 200
      since_id = posts[posts.length-1]?.id
      paginator = new TentStatus.Paginator(new TentStatus.Collections.Posts(posts), { sinceId: since_id })
      paginator.on 'fetch:success', @render
      @set 'posts', paginator

  context: =>
    posts: (_.map @posts?.toArray() || [], (post) =>
      TentStatus.Views.Post::context(post)
    )

  render: =>
    html = super
    @$el.html(html)
    @trigger 'render'

  initPostViews: =>
    _.each ($ 'li.post', @$el), (el) =>
      post_id = ($ el).attr('data-id')
      post = _.find @posts?.toArray() || [], (p) => p.get('id') == post_id
      view = new TentStatus.Views.Post el: el, post: post, parentView: @
      view.trigger 'ready'

  initAutoPaginate: =>
    ($ window).off('scroll.posts').on 'scroll.posts', (e)=>
      height = $(document).height() - $(window).height()
      delta = height - window.scrollY
      if delta < 200
        clearTimeout @_auto_paginate_timeout
        @_auto_paginate_timeout = setTimeout @posts?.nextPage, 0 unless @posts.onLastPage
