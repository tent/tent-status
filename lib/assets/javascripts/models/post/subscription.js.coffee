TentStatus.Models.Subscription = class SubscriptionModel extends TentStatus.Models.Post
  @model_name: 'subscription'
  @id_mapping_scope: ['entity', 'target_entity', 'content.type']

  parseAttributes: (attrs) =>
    super

    @set('target_entity', @get('mentions')[0].entity)

