TentStatus.Collections.StatusReplies = class StatusRepliesCollection extends TentStatus.Collection
  @model: TentStatus.Models.StatusReplyPost
  @id_mapping_scope: ['entity', 'post_id']
  @collection_name: 'replies_collection'

  constructor: ->
    super

    # id mapping
    @set('entity', @options.entity || TentStatus.config.meta.entity)
    @set('post_id', @options.post_id)
