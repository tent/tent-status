class StatusPro.Views.FollowerGroupsForm extends Backbone.View
  initialize: (options = {}) ->
    @parentView = options.parentView

    followerId = @$el.attr 'data-follower-id'
    @follower = StatusPro.Collections.followers.find (follower) -> follower.get('id') == followerId

    @$groupsSelect = ($ 'select[name=groups]', @$el)
    @$groupsSelect.chosen
      persistent_create_option: true
      no_results_text: 'No groups match'
      create_option_text: 'Create new group'
      create_option: (name) =>
        group = new StatusPro.Models.Group({ name: name })
        group.once 'sync', =>
          StatusPro.Collections.groups.push(group)
          @follower.set 'groups', (@follower.get('groups') || []).concat([group.get('id')])
          @follower.save()
          @parentView.render()
        group.save()

    @$groupsSelect.change =>
      @follower.set 'groups', @$groupsSelect.val()
      @follower.once 'sync', => @parentView.render()
      @follower.save()

