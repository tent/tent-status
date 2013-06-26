TentStatus.UnifiedCollectionPool = class UnifiedCollectionPool extends TentStatus.CollectionPool

  collection: => @unified_collection
  shadowCollection: => @shadow_collection

  initShadowCollection: (unified_collection) =>
    @unified_collection = unified_collection
    @shadow_collection = new TentStatus.UnifiedCollection unified_collection.collections()

  reset: =>
    @shadow_collection.empty()
    @interval.reset()

