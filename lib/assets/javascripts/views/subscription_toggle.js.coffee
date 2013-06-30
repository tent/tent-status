Marbles.Views.SubscriptionToggle = class SubscriptionToggleView extends Marbles.View
  @template_name: 'subscription_toggle'
  @view_name: 'subscription_toggle'

  initialize: (options = {}) ->
    @entity = Marbles.DOM.attr(@el, 'data-entity')

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

    # TODO: query for subscriptions

    if @subscription_cids.length
      @subscribed = true
    else
      @subscribed = false

    Marbles.DOM.on @el, 'click', @toggle


  toggle: =>
    if @subscribed
      return false unless confirm("Unsubscribe from #{@entity}?")
      @deleteSubscriptions()
    else
      @createSubscriptions()

  deleteSubscriptions: =>
    el = @parentView().el
    Marbles.DOM.hide(el)

    for cid in @subscription_cids
      model = TentStatus.Models.Subscription.find(cid: cid)
      continue unless model
      model.delete(
        success: =>
          Marbles.DOM.removeNode(el)

        failure: =>
          Marbles.DOM.show(el)
      )

