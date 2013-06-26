Marbles.Views.SearchResults = class SearchResultsView extends Marbles.Views.PostsFeed
  @view_name: 'search_results'

  initialize: (options = {}) =>
    @post_types = options.post_types || TentStatus.config.feed_types

    # fire focus event for first post view in feed (caught by author info view)
    # TODO: find a better way to do this!
    @once 'ready', =>
      first_post_view = @childViews('Post')?[0]
      if first_post_view
        first_post_view.constructor.trigger('focus', first_post_view)

    @on 'ready', @initAutoPaginate

    @params = options.parent_view.params
    setImmediate => @fetch(@params)

  postsCollection: =>
    @_posts_collection ?= new TentStatus.Collections.SearchResults api_root: TentStatus.config.services.search_api_root

