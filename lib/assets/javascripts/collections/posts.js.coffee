TentStatus.Collections.Posts = class PostsCollection extends TentStatus.Collection
  @model: TentStatus.Models.Post
  @id_mapping_scope: ['entity', 'context']
  @collection_name: 'posts_collection'

  constructor: ->
    super

    # id mapping
    @set('entity', @options.entity || TentStatus.config.current_user.entity)
    @set('context', @options.context || 'default')

