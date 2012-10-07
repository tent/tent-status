class TentStatus.Views.ProfileStats extends TentStatus.View
  templateName: '_profile_stats'

  initialize: (options) ->
    super

    @resources = ['posts', 'followers', 'followings']

    @entity = options.parentView.entity
    if TentStatus.config.domain_entity.assertEqual(@entity)
      api_root = TentStatus.config.domain_tent_api_root
    else
      api_root = TentStatus.config.tent_proxy_root + "/#{encodeURIComponent @entity}"

    for r in @resources
      do (r) =>
        @on "change:#{r}Count", @render
        if r == 'posts'
          params = {
            post_types: TentStatus.config.post_types
          }
        else
          params = {}

        new HTTP 'GET', "#{api_root}/#{r}/count", params, (count, xhr) =>
          return unless xhr.status == 200
          @set "#{r}Count", count

    @render()

  context: =>
    postsCount: @postsCount
    followersCount: @followersCount
    followingsCount: @followingsCount
    followers_url: TentStatus.Helpers.followersUrl(@entity)
    followings_url: TentStatus.Helpers.followingsUrl(@entity)

  render: =>
    for r in @resources
      return if @get("#{r}Count") == null or @get("#{r}Count") == undefined
    html = super
    @$el.html(html)
