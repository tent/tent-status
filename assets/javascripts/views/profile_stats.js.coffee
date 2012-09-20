class TentStatus.Views.ProfileStats extends TentStatus.View
  templateName: '_profile_stats'

  initialize: (options) ->
    super
    @container = null

    api_root = if TentStatus.guest_authenticated
      TentStatus.tent_api_root
    else
      TentStatus.api_root

    @countKeys = ['postsCount', 'followingsCount', 'followersCount']
    for key in @countKeys
      @once "change:#{key}", @render

    $.getJSON "#{api_root}/posts/count", (count) =>
      @set 'postsCount', count

    $.getJSON "#{api_root}/followers/count", (count) =>
      @set 'followersCount', count

    $.getJSON "#{api_root}/followings/count", (count) =>
      @set 'followingsCount', count

    @render()

  context: =>
    postsCount: @postsCount
    followersCount: @followersCount
    followingsCount: @followingsCount

  render: =>
    for key in @countKeys
      val = @get(key)
      return if val == null
    html = super
    @$el.html(html)
