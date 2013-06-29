Marbles.Views.RepostVisibility = class RepostVisibilityView extends Marbles.View
  @template_name: 'repost_visibility'
  @view_name: 'repost_visibility'

  @types: TentStatus.config.repost_types

  constructor: ->
    super

    @collection_context = 'repost-visibility+' + sjcl.codec.base64.fromBits(sjcl.codec.utf8String.toBits(JSON.stringify(@constructor.types)))

    @render()
    @fetchReposts()

  postsCollection: =>
    return unless post = @post()

    if @_posts_collection_cid
      return TentStatus.Collections.Posts.find(cid: @_posts_collection_cid)

    collection = TentStatus.Collections.Reposts.find(entity: post.get('entity'), post_id: post.get('id'), context: @collection_context)
    collection ?= new TentStatus.Collections.Reposts(entity: post.get('entity'), post_id: post.get('id'), context: @collection_context)
    collection.options.params = {
      mentions: post.get('entity') + '+' + post.get('id')
      types: @constructor.types
    }
    @_posts_collection_cid = collection.cid

    collection

  post: =>
    @parentView()?.post()

  fetchReposts: =>
    return unless collection = @postsCollection()

    if collection.model_ids.length >= 10
      return @render()

    params = {
      limit: 10
    }
    collection.fetch params, success: (models, res, xhr) =>
      @count = parseInt(xhr.getResponseHeader('Count'))
      @render()

  context: (reposts = []) =>
    count = if @count && @count > 0 then @count - 1 else 0
    _post = @findParentView('post')?.post()
    mentions = @mentions || []
    entity = if _post?.get('is_repost') then _post.get('entity') else _.first(mentions)?.entity

    entity: entity
    count: count
    pluralized_other: TentStatus.Helpers.pluralize('other', count, 'others')
    entities: _.map(reposts, ((post) => post.get('entity')))

