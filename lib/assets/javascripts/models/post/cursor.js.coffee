TentStatus.Models.CursorPost = class CursorPostModel extends TentStatus.Models.Post
  @model_name: 'cursor_post'
  @id_mapping_scope: ['type', 'entity']

  @fetch: (params, options) ->
    callbackFn = (res, xhr) =>
      if xhr.status == 200 && res.posts.length
        if post = @find(params, fetch: false)
          post.parseAttributes(res.posts[0])
        else
          if params.cid
            post = new @(res.posts[0], cid: params.cid)
          else
            post = new @(res.posts[0])

        if res.refs && res.refs.length
          post.ref_post = res.refs[0]

        options.success?(post, xhr)
      else
        options.failure?(res, xhr)

      options.complete?(res, xhr)

    TentStatus.tent_client.post.list(
      params: {
        types: params.type
        entities: params.entity
        max_refs: 1
        limit: 1
      },
      callback: callbackFn
    )

  fetch: (options = {}) =>
    @constructor.fetch({
      cid: @cid
      type: @get('type')
      entity: @get('entity')
    }, options)

