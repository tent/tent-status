Marbles.Views.SitePostsFeed = class SitePostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'site_posts_feed'

  initialize: (options = {}) =>
    site_feed_meta_post = {
      content: {
        servers: [{
          urls: {
            "posts_feed": TentStatus.config.services.site_feed_api_root
          }
        }]
      }
    }

    options.entity = TentStatus.config.meta.content.entity
    options.types = [TentStatus.config.POST_TYPES.STATUS]
    options.feed_queries = [{ entities: false, profiles: 'entity' }]
    options.context = 'site-feed'

    @tent_client = new TentClient(TentStatus.config.meta.content.entity,
      server_meta_post: site_feed_meta_post
    )

    @tent_client.middleware = [{ # reset middleware to remove auth header
      processRequest: (request) ->
        request.request.xmlhttp.withCredentials = true
    }]

    super(options)

  shouldAddPostToFeed: (post) =>
    post.get('permissions.public') == true && !post.is_repost
