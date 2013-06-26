TentStatus.UnifiedCollection = class UnifiedCollection extends Marbles.UnifiedCollection

  sortModelsBy: (model) =>
    model.get('received_at') * -1

  fetchPrev: (options = {}) =>
    collections = _.select @collections(), (c) => !!c.pagination.prev
    prev_params = null
    for collection in collections
      continue unless collection.pagination.prev
      prev_params ?= {}
      prev_params[collection.cid] = Marbles.History::parseQueryParams(collection.pagination.prev)
    return false unless prev_params
    @fetch(prev_params, _.extend({ prepend: true }, options))

  fetchNext: (options = {}) =>
    collections = _.select @collections(), (c) => !!c.pagination.next
    next_params = null
    for collection in collections
      continue unless collection.pagination.next
      next_params ?= {}
      next_params[collection.cid] = Marbles.History::parseQueryParams(collection.pagination.next)
    return false unless next_params
    @fetch(next_params, _.extend({ append: true }, options))

  postTypes: =>
    types = []
    for collection in @collections()
      types.push(collection.postTypes()...)
    _.uniq(types)