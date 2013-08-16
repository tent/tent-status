Marbles.Views.RepostVisibility = class RepostVisibilityView extends Marbles.View
  @template_name: 'repost_visibility'
  @view_name: 'repost_visibility'

  @types: TentStatus.config.repost_types

  constructor: ->
    super

    _post = @findParentView('post')?.post()
    @entity = if _post?.get('is_repost') then _post.get('entity') else null

    @reposter_profile_cids = {}
    setImmediate => @initialFetchReposters()

    @render()

  post: =>
    @parentView()?.post()

  initialFetchReposters: =>
    return unless post = @post()

    params = {
      entity: post.get('entity')
      post: post.get('id')
      profiles: 'entity'
      limit: 60
    }

    @fetchReposters(params)

  isRepostType: (type) =>
    for t in @constructor.types
      return true if type == t
    false

  fetchReposters: (params) =>
    return unless params.entity && params.post

    TentStatus.tent_client.post.mentions(
      params: params
      callback: (res, xhr) =>
        return unless xhr.status == 200

        for mention in res.mentions
          continue unless @isRepostType(mention.type)
          profile = TentStatus.Models.MetaProfile.find(entity: mention.entity, fetch: false)
          if !profile && _profile_attrs = res.profiles[mention.entity]
            profile = new TentStatus.Models.MetaProfile(_profile_attrs)

          @reposter_profile_cids[mention.entity] = profile?.cid

        @render() if Object.keys(@reposter_profile_cids).length

        if res.pages.next
          _.extend(params, Marbles.history.deserializeParams(res.pages.next))
          @fetchReposters(params)
    )

  context: =>
    entity: @entity
    count: @count
    pluralized_other: if @count then TentStatus.Helpers.pluralize('other', @count, 'others') else null
    entities: Object.keys(@reposter_profile_cids)

