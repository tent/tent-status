TentStatus.UnifiedCollectionPool = class UnifiedCollectionPool extends TentStatus.CollectionPool

  constructor: (unified_collection) ->
    super

    TentStatus.Models.StatusPost.on 'create:success', (post, xhr) =>
      @shadow_collection.ignoreModelId(post.cid)

  collection: => @unified_collection
  shadowCollection: => @shadow_collection

  initShadowCollection: (unified_collection) =>
    @unified_collection = unified_collection
    @shadow_collection = new TentStatus.UnifiedCollection unified_collection.collections()

  reset: =>
    @shadow_collection.empty()

    @interval.reset()

  updatePagination: => # ignore

