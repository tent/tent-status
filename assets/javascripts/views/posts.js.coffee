class TentStatus.Views.Posts extends TentStatus.View
  templateName: 'posts'

  initialize: ->
    @container = TentStatus.Views.container
    super

  postsFeedView: =>
    return unless @child_views
    return unless views = (@child_views.PostsFeed or @child_views.DomainPostsFeed)
    views[0]

