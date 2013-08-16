Marbles.Views.ProfileResourceCount = class FollowersCountView extends Marbles.View
  @template_name: 'profile/resource_count'

  constructor: (options = {}) ->
    super

    @render()

    return unless profile = @profile()
    @constructor.model.fetchCount {entities: profile.get('entity')},
      failure: (res, xhr) =>

      success: (count) =>
        @render(@context(count))

  profile: => @parentView().profile()

  context: (count) =>
    profile = @profile()

    url: TentStatus.Helpers.route(@constructor.route, {entity: profile.get('entity')})
    count: count
    pluralized_resource_name: TentStatus.Helpers.capitalize TentStatus.Helpers.pluralize(@constructor.resource_name.singular, count, @constructor.resource_name.plural)

