class TentStatus.Views.ProfileStats extends TentStatus.View
  templateName: '_profile_stats'

  initialize: (options) ->
    super

    @resources = ['posts', 'followers', 'followings']

    for r in @resources
      do (r) =>
        @on "change:#{r}Count", @render
        new HTTP 'GET', "#{TentStatus.config.current_tent_api_root}/#{r}/count", null, (count, xhr) =>
          return unless xhr.status == 200
          @set "#{r}Count", count

    @render()

  context: =>
    postsCount: @postsCount
    followersCount: @followersCount
    followingsCount: @followingsCount

  render: =>
    for r in @resources
      return if @get("#{r}Count") == null or @get("#{r}Count") == undefined
    html = super
    @$el.html(html)
