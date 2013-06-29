TentStatus.Models.Subscription = class SubscriptionModel extends TentStatus.Models.Post
  @model_name: 'subscription'

  targetEntity: =>
    @get('mentions')[0].entity

