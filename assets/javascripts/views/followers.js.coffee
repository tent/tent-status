class TentStatus.Views.Followers extends TentStatus.View
  templateName: 'followers'
  partialNames: ['_follower']

  dependentRenderAttributes: ['followers']

  initialize: ->
    @container = TentStatus.Views.container
    super

    @on 'ready', @initFollowerViews
    @on 'ready', @initAutoPaginate

    @on 'change:followers', @render
    new HTTP 'GET', "#{TentStatus.config.current_tent_api_root}/followers", { limit: TentStatus.config.PER_PAGE }, (followers, xhr) =>
      return unless xhr.status == 200
      followers = new TentStatus.Collections.Followers followers
      paginator = new TentStatus.Paginator followers, { sinceId: followers.last()?.get('id') }
      paginator.on 'fetch:success', @render
      @set 'followers', paginator

  context: =>
    followers: _.map(@followers?.toArray() || [], (follower) =>
      TentStatus.Views.Follower::context(follower)
    )
    guest_authenticated: !!TentStatus.guest_authenticated

  initFollowerViews: =>
    _.each ($ '.follower', @container.$el), (el) =>
      follower_id = ($ el).attr 'data-id'
      follower = @followers.find (f) => f.get('id') == follower_id
      view = new TentStatus.Views.Follower el: el, follower: follower, parentView: @
      view.trigger 'ready'

  initAutoPaginate: =>
    ($ window).off('scroll.followers').on 'scroll.followers', @windowScrolled
    setTimeout @windowScrolled, 100

  windowScrolled: =>
    $last = ($ 'tr.follower:last', @container)
    height = $(document).height() - $(window).height() - ($last.offset()?.top || 0)
    delta = height - window.scrollY

    if delta < 300
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @followers?.nextPage, 0 unless @followers?.onLastPage
