class Reposted extends TentStatus.Events
  separator: "__SEP__"

  constructor: ->
    @params = {
      post_types: "https://tent.io/types/post/repost/v0.1.0"
      entity: TentStatus.config.current_entity.toStringWithoutSchemePort()
      limit: 50
    }

    if since_id = TentStatus.Cache.get @_sinceIdCacheKey()
      @params.since_id = since_id

    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/posts", @params, (reposts, xhr) =>
      return unless xhr.status == 200
      return unless reposts and reposts.length
      TentStatus.Cache.set @_sinceIdCacheKey(), _.first(reposts).id, {saveToLocalStorage:true}
      for repost in reposts
        post_id = repost.content.id
        post_entity = repost.content.entity
        @setReposted post_id, post_entity, @params.entity

  on: (event, entity, post_id, fn) =>
    if event == 'change' and entity and post_id
      is_reposted = @isReposted(post_id, entity)
      fn?(is_reposted) if is_reposted
    super("#{event}#{@separator}#{entity}#{@separator}#{post_id}", fn)

  setReposted: (post_id, post_entity, current_entity = @params.entity) =>
    TentStatus.Cache.set @_cacheKey(post_id, post_entity, current_entity), true, {saveToLocalStorage:true}
    @trigger "change#{@separator}#{post_entity}#{@separator}#{post_id}", true

  unsetReposted: (post_id, post_entity, current_entity = @params.entity) =>
    TentStatus.Cache.remove @_cacheKey(post_id, post_entity, current_entity)
    @trigger "change#{@separator}#{post_entity}#{@separator}#{post_id}", false

  isReposted: (post_id, post_entity, current_entity = @params.entity) =>
    !!(TentStatus.Cache.get @_cacheKey(post_id, post_entity, current_entity))

  _cacheKey: (post_id, post_entity, current_entity) =>
    "reposted:#{current_entity}#{@separator}#{post_entity}#{@separator}#{post_id}"

  _sinceIdCacheKey: => "reposted:#{@params.entity}:since_id"

TentStatus.Reposted = new Reposted
