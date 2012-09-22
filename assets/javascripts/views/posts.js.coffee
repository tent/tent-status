class TentStatus.Views.Posts extends TentStatus.View
  templateName: 'posts'
  partialNames: ['_new_post_form']

  initialize: ->
    @container = TentStatus.Views.container
    super

