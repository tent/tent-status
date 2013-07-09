Marbles.Views.SubscriptionToggle = class SubscriptionToggleView extends Marbles.View
  @template_name: 'subscription_toggle'
  @view_name: 'subscription_toggle'

  constructor: (options = {}) ->
    options.render_method = 'replace'
    super(options)

  initialize: (options = {}) ->
    @entity = Marbles.DOM.attr(@el, 'data-entity')
    @reset()

  reset: =>
    if @entity == TentStatus.config.current_user.entity
      @subscribed = true
      @me = true
      @finalize()
      return

    @subscription_cids = _.inject(TentStatus.config.subscription_types, ((memo, type) =>
      _model = TentStatus.Models.Subscription.find(
        entity: TentStatus.config.current_user.entity,
        target_entity: @entity,
        'content.type': type
        fetch: false
      )
      memo.push(_model.cid) if _model
      memo
    ), [])

    if @subscription_cids.length
      @subscribed = true
    else
      @subscribed = false

    @my_feed = @parentView().getEntity() == TentStatus.config.current_user.entity

    unless @my_feed
      params = {
        types: TentStatus.config.subscription_feed_types,
        mentions: @entity
      }
      _collection_context = TentStatus.Collections.Posts.generateContext('subscription', params)
      collection = TentStatus.Collections.Posts.find(entity: TentStatus.config.current_user.entity, context: _collection_context)
      collection = new TentStatus.Collections.Posts(entity: TentStatus.config.current_user.entity, context: _collection_context)
      collection.options.params = params

      collection.fetch({},
        success: (posts, xhr) =>
          if posts.length
            @subscription_cids = _.map(posts, (post) => post.cid)
            console.log @subscription_cids
            @subscribed = true
          else
            @subscribed = false

          @finalize()

        failure: (res, xhr) =>
          @subscribed = false

          @finalize()
      )
    else
      @finalize()


  finalize: =>
    @render()

    return if @me

    @on 'ready', @bindEl
    @bindEl()

  bindEl: =>
    Marbles.DOM.removeClass(@el, 'disabled')
    Marbles.DOM.on @el, 'click', @toggle

  toggle: =>
    if @subscribed
      return false unless confirm("Unsubscribe from #{@entity}?")
      @deleteSubscriptions()
    else
      @createSubscriptions()

  createSubscriptions: =>
    Marbles.DOM.addClass(@el, 'disabled')
    @el.innerText = '...'

    TentStatus.Models.Following.create @entity,
      failure: (res, xhr) =>
        @render()

      success: (following) =>
        @reset()

  deleteSubscriptions: =>
    el = @parentView().el
    Marbles.DOM.hide(el) if @my_feed

    for cid in @subscription_cids
      model = TentStatus.Models.Subscription.find(cid: cid)
      continue unless model
      model.delete(
        success: =>
          if @my_feed
            Marbles.DOM.removeNode(el)
          else
            @reset()

        failure: =>
          Marbles.DOM.show(el)
      )

  context: =>
    subscribed: @subscribed
    me: !!@me

