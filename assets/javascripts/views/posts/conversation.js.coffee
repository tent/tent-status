class StatusApp.Views.Conversation extends StatusApp.Views.Posts
  templateName: 'conversation'

  context: =>
    postId = @posts.first().get('id')
    data = super
    posts = []
    for post in data.posts
      if postId == post.id
        data.post = post
      else
        posts.push post
    data.posts = posts
    data
