Marbles.Views.RepliesPostsFeed = class RepliesPostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'replies_posts_feed'

  initialize: (options = {}) =>
    options.entity = options.parent_view.entity
    options.types = [TentStatus.config.POST_TYPES.STATUS_REPLY]
    options.feed_queries = [{
      mentions: options.entity
      entities: false
    }]
    super(options)

    collection = @postsCollection()
    collection.on 'reset', @clearRepliesUnreadCount
    collection.on 'prepend', @clearRepliesUnreadCount

  shouldAddPostToFeed: (post) =>
    super && post.isEntityMentioned(@entity)

  clearRepliesUnreadCount: =>
    ref = @postsCollection().first()
    for cid in Marbles.View.instances.replies_unread_count
      continue unless v = Marbles.View.instances.all[cid]
      v.clearCount(ref)

