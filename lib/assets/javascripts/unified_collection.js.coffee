TentStatus.UnifiedCollection = class UnifiedCollection extends Marbles.UnifiedCollection
  pagination: {}
  ignore_model_cids: {}

  sortModelsBy: (model) =>
    (model.get('received_at') || model.get('published_at')) * -1

  fetchPrev: (options = {}) =>
    prev_params = null
    for cid, _pagination of @pagination
      continue unless _pagination.prev
      prev_params ?= {}
      prev_params[cid] = Marbles.History::parseQueryParams(_pagination.prev)
    return false unless prev_params
    @fetch(prev_params, _.extend({ prepend: true }, options))

  fetchNext: (options = {}) =>
    next_params = null
    for cid, _pagination of @pagination
      continue unless _pagination.next
      next_params ?= {}
      next_params[cid] = Marbles.History::parseQueryParams(_pagination.next)
    return false unless next_params
    @fetch(next_params, _.extend({ append: true }, options))

  ignoreModelId: (cid) =>
    @ignore_model_cids[cid] = true

  postTypes: =>
    types = []
    for collection in @collections()
      types.push(collection.postTypes()...)
    _.uniq(types)

  fetch: (params = {}, options = {}) =>
    for cid in @collection_ids
      do (cid) =>
        _completeFn = options[cid]?.complete
        options[cid] ?= {}
        options[cid].complete = (models, res, xhr, _params) =>
          _completeFn?.apply?(null, arguments)

          return unless xhr.status == 200

          _pagination = _.extend({
            first: @pagination[cid]?.first
            last: @pagination[cid]?.last
          }, _.clone(res.pages))

          if _pagination.next && models.length != res.posts.length
            if models.length
              # sometimes not all the results are used
              # in this case we need to create our own `next` query
              _last_model = _.last(models)
              _before = "before=#{_last_model.get('received_at') || _last_model.get('published_at')} #{_last_model.get('version.id')}"
              _pagination.next = _pagination.next.replace(/before=[^&]+/, _before)
            else
              # in the case that no models are returned,
              # just use the same query as last time
              _pagination.next = @pagination[cid]?.next || Marbles.history.serializeParams(_params)
          else if models.length != res.posts.length
            # in the case that no models are returned
            # and there is only a single, non-empty page
            _pagination.next = Marbles.history.serializeParams(_params)

          if options.prepend # fetchPrev
            _pagination.next = @pagination[cid]?.next

          @pagination[cid] = _pagination

          unless @pagination[cid].prev
            model = @constructor.collection.find(cid: cid)?.first()
            since = model?.get('received_at') || model?.get('published_at') || (new Date * 1)
            if version_id = model?.get('version.id')
              since = "#{since} #{version_id}"
            @pagination[cid].prev = "?since=#{since}"

    super(params, options)

  fetchCount: (params = {}, options = {}) =>
    num_pending = @collection_ids.length
    count = 0
    is_success = false
    xhrs = []
    completeFn = (_count, xhr) =>
      num_pending -= 1
      xhrs.push(xhr)

      if xhr.status == 200
        is_success = true
        count += _count

      return unless num_pending <= 0

      if is_success
        options.success?(count, xhrs)
        options.complete?(count, xhrs)
      else
        options.failure?(count, xhrs)
        options.complete?(count, xhrs)

    for cid in @collection_ids
      collection = @constructor.collection.find(cid: cid)
      unless collection
        num_pending -= 1
        continue

      collection.fetchCount(params, complete: completeFn)

  fetchSuccess: (new_models, options) =>
    new_models = _.uniq(new_models, is_sorted = true)
    _new_models = []
    for model in new_models
      continue if @ignore_model_cids[model.cid]
      _new_models.push(model)
    super(_new_models, options)

