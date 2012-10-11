TentStatus.Views.num_followers = new class NumFollowers extends Backbone.View
  initialize: ->
    @setElement document.getElementById('num_followings')

    new HTTP 'GET', "#{TentStatus.config.tent_api_root}/followings/count", null, (count, xhr) =>
      return unless xhr.status == 200
      return if count == null
      @updateCount(count)

  updateCount: (count) =>
    @$el.text(count)
