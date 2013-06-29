Marbles.Views.RepostsPostsFeed = class RepostsPostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'replies_posts_feed'

  initialize: (options = {}) =>
    options.entity = options.parent_view.entity
    options.types = TentStatus.config.repost_types
    options.feed_queries = [{
      mentions: options.entity
    }]
    super(options)

  shouldAddPostToFeed: (post) =>
    super && post.isEntityMentioned(@entity)

