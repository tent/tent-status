TentStatus.CollectionPool = class CollectionPool
  MAX_OVERFLOW_SIZE: 100

  constructor: (collection) ->
    @collection_cid = collection.cid

    shadow_collection = @initShadowCollection(collection)

    @interval = new TentStatus.FetchInterval fetch_callback: @fetch

    collection.on 'reset', => @reset()
    collection.on 'prepend', => @updatePagination(collection.first())

    @reset()

  initShadowCollection: (collection) =>
    shadow_collection = new collection.constructor
    @shadow_collection_cid = shadow_collection.cid
    shadow_collection

  collection: => TentStatus.Collection.find(cid: @collection_cid)
  shadowCollection: => TentStatus.Collection.find(cid: @shadow_collection_cid)

  reset: =>
    collection = @collection()
    shadow_collection = @shadowCollection()

    console.log('collection_cid', @collection_cid, collection)
    console.log('shadow_collection_cid', @shadow_collection_cid, shadow_collection)

    shadow_collection.empty()

    shadow_collection.params = collection.params
    shadow_collection.pagination_params = {}
    if collection.pagination_params.prev
      shadow_collection.pagination_params.prev = collection.pagination_params.prev
    else
      @updatePagination(collection.first())

    @interval.reset()

  updatePagination: (latest_post) =>
    shadow_collection = @shadowCollection()

    if latest_post
      shadow_collection.pagination_params.prev = {
        since: (latest_post.get('received_at') || latest_post.get('published_at')) + " " + latest_post.get('version.id')
      }
    else
      shadow_collection.pagination_params.prev = {
        since: (new Date) * 1
      }

  fetch: =>
    @shadowCollection().fetchPrev success: @fetchSuccess, failure: @fetchFailure

  fetchSuccess: (models, res, xhr, params, options) =>
    if models.length
      shadow_collection = @shadowCollection()

      size = shadow_collection.model_ids.length
      if size > @MAX_OVERFLOW_SIZE
        shadow_collection.empty()
        @trigger("pool:overflow", size)
      else
        @trigger("pool:expand", size)

      @updatePagination(shadow_collection.first())
      @interval.reset()
    else
      @interval.increaseDelay()

  fetchFailure: (res, xhr, params, options) =>
    @interval.increaseDelay()

_.extend CollectionPool::, Marbles.Accessors, Marbles.Events
