class TentStatus.Views.FollowingGroupsForm extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    followingId = @$el.attr 'data-following-id'
    @following = TentStatus.Collections.followings.get(followingId)

    @$groupsSelect = ($ 'select[name=groups]', @$el)
    @$groupsSelect.chosen
      persistent_create_option: true
      no_results_text: 'No groups match'
      create_option_text: 'Create new group'
      create_option: (name) =>
        group = new TentStatus.Models.Group({ name: name })
        group.once 'sync', =>
          TentStatus.Collections.groups.push(group)
          @following.set 'groups', (@following.get('groups') || []).concat([group.get('id')])
          @following.save()
          @parentView.render()
        group.save()

    @$groupsSelect.change =>
      @following.set 'groups', @$groupsSelect.val()
      @following.once 'sync', => @parentView.render()
      @following.save()
