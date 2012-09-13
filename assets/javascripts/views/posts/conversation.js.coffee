class StatusPro.Views.Conversation extends StatusPro.Views.Posts
  templateName: 'conversation'

  context: =>
    data = super
    data.post = data.posts.shift()
    data
