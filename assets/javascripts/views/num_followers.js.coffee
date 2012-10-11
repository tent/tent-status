TentStatus.Views.num_followers = new class NumFollowers extends Backbone.View
  initialize: ->
    @setElement document.getElementById('num_followers')

    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/followers/count", null, (count, xhr) =>
      return unless xhr.status == 200
      return if count == null
      @updateCount(count)

  updateCount: (count) =>
    @$el.text(count)
