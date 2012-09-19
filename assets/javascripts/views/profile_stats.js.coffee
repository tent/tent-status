class StatusApp.Views.ProfileStats extends StatusApp.View
  templateName: '_profile_stats'

  dependentRenderAttributes: ['postsCount', 'followingsCount', 'followersCount']

  initialize: (options) ->
    return unless StatusApp.current_entity == options.parentView.currentProfile?.entity()
    super
    @container = null

    $.getJSON "#{StatusApp.api_root}/posts/count", (count) =>
      @set 'postsCount', count

    $.getJSON "#{StatusApp.api_root}/followers/count", (count) =>
      @set 'followersCount', count

    $.getJSON "#{StatusApp.api_root}/followings/count", (count) =>
      @set 'followingsCount', count

    @render()

  context: =>
    postsCount: @postsCount
    followersCount: @followersCount
    followingsCount: @followingsCount

  render: =>
    html = super
    @$el.html(html)
