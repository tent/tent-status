Marbles.Views.SubscriptionsFeed = class SubscriptionsFeedView extends Marbles.Views.PostsFeed
  @template_name: 'subscriptions_feed'
  @partial_names: ['subscription']
  @view_name: 'subscriptions_feed'

  initialize: (options = {}) =>
    options.types = TentStatus.config.subscription_feed_types
    options.entity = options.parent_view.entity
    options.headers = {
      'Cache-Control': 'proxy'
    }
    options.feed_queries = [
      { types: options.types, profiles: 'mentions' }
    ]

    super(options)

    if TentStatus.config.meta.entity == options.parent_view.entity
      TentStatus.Models.Subscription.on 'create:success', (post, xhr) =>
        return unless @shouldAddPostToFeed(post)
        collection = @postsCollection()
        return unless @shouldAddPostTypeToFeed(post.get('type'), collection.postTypes())
        collection.unshift(post)
        @render()

  getEntity: =>
    @parentView()?.entity

  shouldAddPostToFeed: (post) =>
    true

  groupSubscriptions: (subscriptions) =>
    _.inject subscriptions, ((memo, subscription) =>
      memo[subscription.get('target_entity')] ?= []
      memo[subscription.get('target_entity')].push(subscription)
      memo
    ), {}

  context: (subscriptions = @postsCollection().models()) =>
    subscriptions: @groupSubscriptions(subscriptions)

