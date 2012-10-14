class TentStatus.Views.PostDetails extends TentStatus.View
  templateName: 'post_details'
  partialNames: ['_post', '_post_inner', '_reply_form']

  initialize: (options = {}) ->
    super

    @parentView = options.parentView
    return unless @parentView.post

    @render()

    @on 'change:parent_posts', @render
    @on 'change:child_posts', @render

    @on 'ready', @initPostViews
    @on 'ready', @bindEvents

    @fetchParentPosts()
    @fetchChildPosts()

  unbind: => @off()

  fetchParentPosts: =>
    TentStatus.trigger 'loading:start'
    @parentView.post.fetchParents (posts) =>
      TentStatus.trigger 'loading:complete'
      @set 'parent_posts', posts

  fetchChildPosts: =>
    TentStatus.trigger 'loading:start'
    @parentView.post.fetchChildren (posts) =>
      TentStatus.trigger 'loading:complete'
      @set 'child_posts', posts

  context: =>
    post: @parentView.context()
    parent_posts: (_.map (@parent_posts?.toArray() || []), (p) => if p then @parentView.constructor::context(p))
    child_posts: (_.map (@child_posts?.toArray() || []), (p) => @parentView.constructor::context(p))

  render: =>
    html = super
    return unless html

    el = ($ html)
    @parentView.$el.replaceWith(el)
    @parentView.setElement el

    @trigger 'ready'

  initPostView: (post, el) =>
    view = new TentStatus.Views.Post post: post, el: el, parentView: @
    view.showDetils = ->
    view.hideDetails = ->
    view.trigger 'ready'

  initPostViews: =>
    post_els = ($ 'li.post', @parentView.$el).toArray()

    for post in (@parent_posts?.toArray() || [])
      el = post_els.shift()
      @initPostView post, el

    @initPostView @parentView.post, post_els.shift()

    for post in (@child_posts?.toArray() || [])
      el = post_els.shift()
      @initPostView post, el

  bindEvents: =>
    @parentView.$el.on 'click.hide_details', (e) =>
      unless e.target.tagName.toLowerCase() == 'a' || (_.find $(e.target).parents(), (el)=> el.tagName.toLowerCase() == 'a')
        @unbind()
        @parentView.render()

