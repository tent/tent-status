Marbles.Views.RepostsPostsFeed = class RepostsPostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'replies_posts_feed'

  initialize: (options = {}) =>
    options.entity = options.parent_view.entity
    options.types = TentStatus.config.repost_types
    options.feed_queries = [{
      mentions: options.entity
      entities: false
      profiles: 'entity'
    }]
    super(options)

    collection = @postsCollection()
    collection.on 'reset', @clearRepostsUnreadCount
    collection.on 'prepend', @clearRepostsUnreadCount

  shouldAddPostToFeed: (post) =>
    super && post.isEntityMentioned(@entity)

  clearRepostsUnreadCount: =>
    ref = @postsCollection().first()
    for cid in Marbles.View.instances.reposts_unread_count
      continue unless v = Marbles.View.instances.all[cid]
      v.clearCount(ref)

