Marbles.Views.MentionsPostsFeed = class MentionsPostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'mentions_posts_feed'
  @last_post_selector: "ul[data-view=MentionsPostsFeed]>li.post:last-of-type"

  initialize: (options = {}) =>
    options.entity = options.parent_view.entity
    options.types = [TentStatus.config.POST_TYPES.STATUS_REPLY, TentStatus.config.POST_TYPES.STATUS]
    options.feed_queries = [{
      mentions: options.entity
      entities: false
      profiles: 'entity'
    }]
    super(options)

    collection = @postsCollection()
    collection.on 'reset', @clearRepliesUnreadCount
    collection.on 'prepend', @clearRepliesUnreadCount

  shouldAddPostToFeed: (post) =>
    super && post.isEntityMentioned(@entity)

  clearRepliesUnreadCount: =>
    ref = @postsCollection().first()
    for cid in Marbles.View.instances.mentions_unread_count
      continue unless v = Marbles.View.instances.all[cid]
      v.clearCount(ref)

