class TentStatus.Views.ConversationPostsFeed extends TentStatus.Views.PostsFeed
  view_name: 'conversation_posts_feed'

  initialize: (options = {}) ->
    @parentView = options.parentView
    return unless @parentView.posts?.length

    @on 'ready', @initAutoPaginate

    TentStatus.View::initialize.apply(this, arguments)

    @initPagination()

  initPagination: =>
    paginator = new TentStatus.ChildPostsPaginator(@parentView.post, @parentView.posts)
    paginator.on 'fetch:success', @appendRender
    @set 'posts', paginator

    @trigger 'ready'

  appendRender: (new_posts) =>
    html = ""
    $last_post = $('.post:last', @$el)
    new_posts = for post in new_posts.toArray()
      html += TentStatus.Views.Post::renderHTML(TentStatus.Views.Post::context(post), @partials)
      post

    @$el.append(html)
    _.each $last_post.nextAll('.post'), (el, index) =>
      view = new TentStatus.Views.Post el: el, post: new_posts[index], parentView: @
      view.trigger 'ready'
