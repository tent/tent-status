Marbles.Views.SubscriptionsFeed = class SubscriptionsFeedView extends Marbles.Views.PostsFeed
  @template_name: 'subscriptions_feed'
  @partial_names: ['subscription']
  @view_name: 'subscriptions_feed'

  initialize: (options = {}) =>
    options.types = TentStatus.config.subscription_feed_types
    options.feed_queries = [
      { types: options.types, profiles: 'mentions' }
    ]

    super(options)

  shouldAddPostTypeToFeed: (prospect_type, types = @postsCollection().postTypes()) =>
    console.log(prospect_type, types)
    super(prospect_type, types)

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

