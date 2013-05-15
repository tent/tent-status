TentStatus.Collection = class Collection extends Marbles.Collection
  pagination: {}

  constructor: (options = {}) ->
    super(_.extend(unique: true, options))

  @buildModel: (attrs, options = {}) ->
    if attrs.type == TentStatus.config.POST_TYPES.STATUS
      options.model = TentStatus.Models.StatusPost

    super(attrs, options)

  postTypes: =>
    @options.params.types || []

  fetchNext: (options = {}) =>
    return false unless @pagination.next
    next_params = Marbles.History::parseQueryParams(@pagination.next)
    @fetch(next_params, _.extend({ append: true }, options))

  fetch: (params = {}, options = {}) =>
    complete = (res, xhr) =>
      models = null
      if xhr.status in [200...300]
        models = @fetchSuccess(params, options, res, xhr)
        options.success?(models, res, xhr, params, options)
        @trigger('fetch:success', models, res, xhr, params, options)
        # success
      else
        options.failure?(res, xhr, params, options)
        @trigger('fetch:failure', res, xhr, params, options)
      options.complete?(models, res, xhr, params, options)
      @trigger('fetch:complete', models, res, xhr, params, options)

    params = _.extend {
      entity: TentStatus.config.current_user.entity
      types: [@constructor.model.post_type]
      limit: TentStatus.config.PER_PAGE
    }, @options.params, params

    params.types = [params.types] unless _.isArray(params.types)
    params.types = _.map params.types, (type) => (new TentClient.PostType type).toURIString()

    TentStatus.tent_client.post.list(params: params, callback: complete)

  fetchSuccess: (params, options, res, xhr) =>
    @pagination = _.extend({
      first: @pagination.first
      last: @pagination.last
    }, res.pages)

    data = res.data

    models = if options.append
      @appendJSON(data)
    else if options.prepend
      @prependJSON(data)
    else
      @resetJSON(data)

    models

