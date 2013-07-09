Marbles.Views.Relationship = class RelationshipView extends Marbles.View
  @view_name: 'relationship'
  @template_name: 'relationship'

  getEntity: =>
    @parentView()?.getEntity?()
