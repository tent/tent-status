Marbles.Views.ProfilePostsFeed = class ProfilePostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'profile_posts_feed'
  @last_post_selector: "ul[data-view=ProfilePostsFeed]>li.post:last-of-type"

  initialize: (options = {}) =>
    options.entity = @findParentView('profile').profile().get('entity')
    options.headers = {
      'Cache-Control': 'proxy'
    }
    super(options)

  shouldAddPostToFeed: (post) =>
    return false unless post.get('entity') == @entity
    true

