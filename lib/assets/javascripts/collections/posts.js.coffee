TentStatus.Collections.Posts = class PostsCollection extends TentStatus.Collection
  @model: TentStatus.Models.Post
  @id_mapping_scope: ['entity', 'context']
  @collection_name: 'posts_collection'

  @generateContext: (name, params) ->
    name + '+' + sjcl.codec.base64.fromBits(sjcl.codec.utf8String.toBits(JSON.stringify(params)))

  constructor: ->
    super

    # id mapping
    @set('entity', @options.entity || TentStatus.config.meta.content.entity)
    @set('context', @options.context || 'default')

