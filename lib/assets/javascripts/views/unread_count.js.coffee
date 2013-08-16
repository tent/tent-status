Marbles.Views.UnreadCount = class UnreadCountView extends Marbles.View
  @view_name: 'unread_count'

  initialize: ->
    @interval = new TentStatus.FetchInterval fetch_callback: @fetchCount
    @cursor_interval = new TentStatus.FetchInterval fetch_callback: @fetchCursor

    # find or fetch existing cursor post
    TentStatus.Models.CursorPost.find(
      {
        type: @constructor.cursor_post_type
        entity: TentStatus.config.meta.content.entity
      },

      success: @fetchSuccess
      failure: @fetchFailure
      complete: =>
        @trigger('fetch:complete')
    )

  fetchCursor: =>
    return unless cursor_post = TentStatus.Models.CursorPost.find(cid: @post_cid)
    cursor_post.fetch(
      params: {
        since: cursor_post.get('received_at') + ' ' + cursor_post.get('version.id')
      }

      success: =>
        @cursor_interval.reset()
        @reset()

      failure: =>
        @cursor_interval.increaseDelay()
    )

  hide: =>
    Marbles.DOM.hide(@el, visibility: true)

  show: =>
    Marbles.DOM.removeClass(@el, 'hidden')
    Marbles.DOM.show(@el, visibility: true)

  clearCount: (ref) =>
    @count = 0
    @render()
    @frozen = true

    unless @post_cid
      return @once 'fetch:complete', => @clearCount(ref)

    post = @getPost()
    post.ref_post = ref
    post.set('refs', [{
      entity: ref.get('entity')
      type: ref.get('type')
      post: ref.get('id')
    }])
    post.set('permissions', { public: false })
    post.saveVersion(
      complete: =>
        if @fetch_count_pending
          @once 'fetch-count:complete', => @frozen = false
        else
          @frozen = false
    )

  getPost: =>
    TentStatus.Models.CursorPost.find(cid: @post_cid)

  fetchSuccess: (post) =>
    @post_cid = post.cid
    @cursor_interval.reset()

    @reset()

  fetchFailure: =>
    post = new TentStatus.Models.CursorPost(
      type: @constructor.cursor_post_type
      entity: TentStatus.config.meta.content.entity
    )
    @post_cid = post.cid

    @reset()

  reset: =>
    @interval.reset()

  fetchParams: =>
    params = {
      types: @constructor.post_types
    }

    post = @getPost()
    if _ref = post.get('ref_post')
      params.since = "#{_ref.received_at || _ref.published_at} #{_ref.version.id || ''}"

    params

  fetchCount: =>
    return if @frozen
    @fetch_count_pending = true

    callbackFn = (res, xhr) =>
      if xhr.status == 200
        @fetchCountSuccess(res, xhr)
      else
        @fetchCountFailure(res, xhr)
      @fetch_count_pending = false
      @trigger('fetch-count:complete')

    params = @fetchParams()
    TentStatus.tent_client.post.list(
      method: 'HEAD'
      params: params
      callback: callbackFn
    )

  fetchCountSuccess: (res, xhr) =>
    return if @frozen

    count = parseInt(xhr.getResponseHeader('Count'))
    return @fetchCountFailure(res, xhr) if _.isNaN(count)
    return @interval.increaseDelay() if count == @count

    @count = count
    @render()

    @interval.reset()

  fetchCountFailure: (res, xhr) =>
    @interval.increaseDelay()
    console.log('fetchCountFailure', res, xhr)

  render: =>
    if @count > 0
      if @count.toString().length > 2
        Marbles.DOM.setInnerText(@el, "99+")
      else
        Marbles.DOM.setInnerText(@el, @count)
      @show()
    else
      @hide()

