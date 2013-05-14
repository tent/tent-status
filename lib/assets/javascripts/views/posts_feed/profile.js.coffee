Marbles.Views.ProfilePostsFeed = class ProfilePostsFeedView extends Marbles.Views.PostsFeed
  @view_name: 'profile_posts_feed'

  initialize: (options = {}) =>
    options.entity = @findParentView('profile').profile().get('entity')
    super(options)

  shouldAddPostToFeed: (post) =>
    return false unless post.get('entity') == @entity
    true

