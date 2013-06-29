Marbles.Views.SubscriptionsFeed = class SubscriptionsFeedView extends Marbles.Views.PostsFeed
  @template_name: 'subscriptions_feed'
  @partial_names: ['subscription']
  @view_name: 'subscriptions_feed'

  initialize: (options = {}) =>
    options.types = TentStatus.config.subscription_types
    options.feed_queries = [
      { types: options.types, profiles: 'mentions' }
    ]

    super(options)

  shouldAddPostToFeed: (post) =>
    true

  context: (subscriptions = @postsCollection().models()) =>
    subscriptions: subscriptions

