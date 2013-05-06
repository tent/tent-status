TentStatus.Collections.Reposts = class RepostsCollection extends TentStatus.Collection
  @model: TentStatus.Models.Post
  @id_mapping_scope: ['entity', 'post_id', 'context']
  @collection_name: 'reposts_collection'

  constructor: ->
    super

    # id mapping
    @set('entity', @options.entity || TentStatus.config.current_user.entity)
    @set('post_id', @options.post_id)
    @set('context', @options.context || 'default')

