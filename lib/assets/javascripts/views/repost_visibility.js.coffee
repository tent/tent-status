Marbles.Views.RepostVisibility = class RepostVisibilityView extends Marbles.View
  @template_name: 'repost_visibility'
  @view_name: 'repost_visibility'

  constructor: ->
    super

    @render()
    @fetchRepostedCount()
    @fetchReposts()

  post: =>
    @parentView()?.post()

  fetchRepostedCount: (client) =>
    return unless post = @post()
    unless client
      return Marbles.HTTP.TentClient.find entity: post.get('entity'), @fetchRepostedCount

    params = {
      entity: post.get('entity')
      post_types: [TentStatus.config.POST_TYPES.REPOST]
      limit: 10
    }
    client.head "posts/#{post.get('id')}/mentions", params,
      success: (res, xhr) =>
        @count = parseInt xhr.getResponseHeader('Count')
        @render()

      error: =>

  fetchReposts: (client) =>
    return unless post = @post()
    unless client
      return Marbles.HTTP.TentClient.find entity: post.get('entity'), @fetchReposts

    params = {
      entity: post.get('entity')
      post_types: [TentStatus.config.POST_TYPES.REPOST]
      limit: 10
    }
    client.get "posts/#{post.get('id')}/mentions", params,
      success: (mentions) =>
        @mentions = mentions
        @render()

      error: =>

  context: =>
    count = if @count && @count > 0 then @count - 1 else 0
    post = @post()
    _post = @findParentView('post')?.post()
    mentions = @mentions || []
    entity = if _post?.isRepost() then _post.get('entity') else _.first(mentions)?.entity

    entity: entity
    count: count
    pluralized_other: TentStatus.Helpers.pluralize('other', count, 'others')
    mentions: _.map( mentions || [], (mention) => { entity: mention.entity } )

