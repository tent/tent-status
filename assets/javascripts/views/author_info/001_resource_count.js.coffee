TentStatus.Views.AuthorInfoResourceCount = class FollowersCountView extends TentStatus.View
  @template_name: '_author_info_resource_count'

  constructor: (options = {}) ->
    super

    profile = @profile()
    @constructor.model.fetchCount {entity: profile.get('entity')},
      error: (res, xhr) =>

      success: (count) =>
        @render(@context(count))

  profile: => @parent_view.profile()

  context: (count) =>
    profile = @profile()

    url: TentStatus.Helpers.entityResourceUrl(profile.get('entity'), @constructor.model.resource_path)
    formatted:
      count: "#{count} #{TentStatus.Helpers.capitalize TentStatus.Helpers.pluralize(@constructor.resource_name.singular, count, @constructor.resource_name.plural)}"

