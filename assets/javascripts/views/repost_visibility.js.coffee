Marbles.Views.RepostVisibility = class RepostVisibilityView extends TentStatus.View
  @template_name: 'repost_visibility'
  @view_name: 'repost_visibility'

  constructor: ->
    super

    @fetchReposts()

  post: =>
    @parentView()?.post()

  fetchReposts: (client) =>
    return unless post = @post()
    unless client
      return HTTP.TentClient.find entity: post.get('entity'), @fetchReposts

    params = {
      entity: post.get('entity')
      post_types: [TentStatus.config.POST_TYPES.REPOST]
      limit: 10
    }
    client.get "posts/#{post.get('id')}/mentions", params,
      success: (mentions) =>
        @render(@context(mentions))

      error: =>

  context: (mentions = {}) =>
    mentions: _.map( mentions, (mention) => { entity: mention.entity } )

