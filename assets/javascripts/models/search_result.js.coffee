TentStatus.Models.SearchResult = class SearchResultModel extends TentStatus.Model
  @model_name: 'search_result'
  @id_mapping_scope: ['id']

  parseAttributes: (attributes) =>
    _attrs = {}

    if profile = TentStatus.Models.Profile.find(entity: attributes.source.entity, fetch: false, include_partial_data: true)
      _attrs.profile_cid = profile.cid
    else
      _profile_attrs = {}
      _profile_attrs[TentStatus.config.PROFILE_TYPES.CORE] = {
        entity: attributes.source.entity
      }
      _profile_attrs[TentStatus.config.PROFILE_TYPES.BASIC] = {
        name: attributes.source.name
        avatar_url: attributes.source.avatar_url
      }
      profile = new TentStatus.Models.Profile(_profile_attrs, partial_data: true)

      _attrs.profile_cid = profile.cid

    if post = TentStatus.Models.Post.find(id: attributes.source.public_id, entity: attributes.source.entity, fetch: false, include_partial_data: true)
      _attrs.post_cid = post.cid
    else
      post = new TentStatus.Models.Post({
        type: attributes.source.post_type
        content: {
          text: attributes.source.content
        }
        entity: attributes.source.entity
        id: attributes.source.public_id
        published_at: attributes.source.published_at
        version: attributes.source.post_version
        permissions:
          public: true
      }, partial_data: true)
      _attrs.post_cid = post.cid

    post.set('profile_cid', _attrs.profile_cid)
    super(_.extend(_attrs, highlight: attributes.highlight, id: attributes.id))

  post: =>
    TentStatus.Model.instances.all[@post_cid]

