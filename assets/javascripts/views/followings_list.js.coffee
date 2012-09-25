class TentStatus.Views.FollowingsList extends TentStatus.View
  templateName: 'followings_list'
  partialNames: ['_following']

  dependentRenderAttributes: ['followings']

  initialize: ->
    super

    @on 'ready', @initFollowingViews
    @on 'ready', @initAutoPaginate

    @on 'change:followings', @render
    new HTTP 'GET', "#{TentStatus.config.current_tent_api_root}/followings", { limit: TentStatus.config.PER_PAGE }, (followings, xhr) =>
      return unless xhr.status == 200
      followings = new TentStatus.Collections.Followings followings
      paginator = new TentStatus.Paginator followings, { sinceId: followings.last()?.get('id') }
      paginator.on 'fetch:success', @render
      @set 'followings', paginator

  context: =>
    followings: _.map( @followings?.toArray() || [], (following) =>
      TentStatus.Views.Following::context(following)
    )

  render: =>
    return unless html = super
    @$el.html(html)

    @trigger 'ready'

  initFollowingViews: =>
    _.each ($ '.following', @$el), (el) =>
      following_id = ($ el).attr 'data-id'
      following = _.find @followings?.toArray() || [], (f) => f.get('id') == following_id
      view = new TentStatus.Views.Following el: el, following: following, parentView: @
      view.trigger 'render'

  initAutoPaginate: =>
    ($ window).off('scroll.followings').on 'scroll.followings', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    $last_post = ($ 'tr.following:last', @$el)
    height = $(document).height() - $(window).height() - $last_post.offset().top
    delta = height - window.scrollY

    if delta < 300
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @followings?.nextPage, 0 unless @followings?.onLastPage

