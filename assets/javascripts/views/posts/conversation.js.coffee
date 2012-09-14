class StatusApp.Views.Conversation extends StatusApp.Views.Posts
  templateName: 'conversation'

  initialize: ->
    @dependentRenderAttributes.push 'post'
    super

  context: =>
    @posts.unshift(@post)
    data = super
    posts = []
    for post in data.posts
      if post.id == @post.get('id')
        data.post = post
      else
        posts.push post
    data.posts = posts
    data
