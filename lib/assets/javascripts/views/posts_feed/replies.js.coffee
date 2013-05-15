Marbles.Views.RepliesPostsFeed = class RepliesPostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'replies_posts_feed'

  initialize: (options = {}) =>
    options.entity = options.parent_view.entity
    options.post_types = [TentStatus.config.POST_TYPES.STATUS_REPLY]
    options.feed_queries = [{
      mentions: options.entity
    }]
    super(options)

  shouldAddPostToFeed: (post) =>
    super && post.isEntityMentioned(@entity)

