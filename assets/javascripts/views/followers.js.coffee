class TentStatus.Views.Followers extends TentStatus.View
  templateName: 'followers'
  partialNames: ['_follower']

  dependentRenderAttributes: ['followers']

  initialize: (options = {}) ->
    @container = TentStatus.Views.container
    @entity = options.entity
    super

    @on 'ready', @initFollowerViews
    @on 'ready', @initAutoPaginate

    if TentStatus.config.domain_entity.assertEqual(@entity)
      api_root = TentStatus.config.domain_tent_api_root
    else
      api_root = "#{TentStatus.config.tent_proxy_root}/#{encodeURIComponent @entity}"

    @on 'change:followers', @render
    TentStatus.trigger 'loading:start'
    url = "#{api_root}/followers"
    new HTTP 'GET', url, { limit: TentStatus.config.PER_PAGE }, (followers, xhr) =>
      TentStatus.trigger 'loading:complete'
      return unless xhr.status == 200
      followers = new TentStatus.Collections.Followers followers
      followers.url = url
      paginator = new TentStatus.Paginator followers, { sinceId: followers.last()?.get('id') }
      paginator.on 'fetch:success', @appendRender
      @set 'followers', paginator

  context: =>
    followers: _.map(@followers?.toArray() || [], (follower) =>
      TentStatus.Views.Follower::context(follower, @entity)
    )
    guest_authenticated: TentStatus.guest_authenticated || !TentStatus.config.domain_entity.assertEqual(@entity)
    profileUrl: TentStatus.Helpers.entityProfileUrl(@entity)
    domain_entity: @entity.toStringWithoutSchemePort()
    formatted:
      domain_entity: TentStatus.Helpers.formatUrl @entity.toStringWithoutSchemePort()

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
    $last = ($ 'tr.follower:last', @container.$el)
    last_offset_top = $last.offset()?.top || 0
    bottom_position = window.scrollY + $(window).height()

    if last_offset_top < (bottom_position + 300)
      clearTimeout @_auto_paginate_timeout
      @_auto_paginate_timeout = setTimeout @followers?.nextPage, 0 unless @followers?.onLastPage

  appendRender: (new_followers) =>
    html = ""
    $el = $('table', @container.$el)
    $last_post = $('.follower:last', $el)
    new_followers = for follower in new_followers
      follower = new TentStatus.Models.Follower follower
      html += TentStatus.Views.Follower::renderHTML(TentStatus.Views.Follower::context(follower, @entity), @partials)
      follower

    $el.append(html)
    _.each $last_post.nextAll('.follower'), (el, index) =>
      view = new TentStatus.Views.Follower el: el, follower: new_followers[index], parentView: @
      view.trigger 'ready'

