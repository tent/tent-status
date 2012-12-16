TentStatus.Views.SitePostsFeed = class SitePostsFeedView extends TentStatus.Views.PostsFeed
  @view_name: 'site_posts_feed'

  init: =>
    @on 'ready', @initPostViews
    @on 'ready', @initAutoPaginate

    @posts_collection = new TentStatus.Collections.Posts
    @posts_collection.client = HTTP.TentClient.hostClient()
    @posts_collection.params = {
      post_types: TentStatus.config.POST_TYPES.STATUS
      limit: TentStatus.config.PER_PAGE
    }
    @fetch()

    TentStatus.Models.Post.on 'create:success', (post, xhr) =>
      return unless post.get('permissions.public') == true
      @posts_collection.unshift(post)
      @prependRender([post])
