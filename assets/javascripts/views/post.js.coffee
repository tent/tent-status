class TentStatus.Views.Post extends TentStatus.View
  templateName: '_post'

  @insertNewPost: (post, container, parentView) ->
    el = ($ '<li>')
    container.prepend(el)
    view = new TentStatus.Views.Post post: post, el: el, parentView: parentView
    view.render()

  initialize: (options = {}) ->
    @parentView = options.parentView
    @post = options.post

    if @post
      @initPostEvents()
    else
      @once 'change:post', @initPostEvents

    @on 'ready', @fetchRepost
    @on 'ready', @bindEvents

    super

  initPostEvents: =>
    @post.on 'change:profile', => @render()
    @post.on 'change:disable_repost', => @render()

  fetchRepost: =>
    if @post?.isRepost() && !@post.get('repost')
      @$el.hide()
      @post.on 'change:repost', =>
        repost = @post.get('repost')
        repost.on 'change:profile', => @render()
        repost.on 'change:disable_repost', => @render()
        @render()
        @$el.show()
      @post.fetchRepost()

  bindEvents: =>
    @$buttons = {
      delete: ($ '.actions .delete:not(.delete-repost)', @$el)
      repost: ($ '.actions .repost:not(.repost-repost)', @$el)
      reply:  ($ '.actions .reply:not(.reply-repost)', @$el)

      delete_repost: ($ '.actions .delete.delete-repost', @$el)
      repost_repost: ($ '.actions .repost.repost-repost', @$el)
      reply_repost: ($ '.actions .reply.reply-repost', @$el)
    }

    @$reply_container = ($ '.reply-container:not(.repost-reply-container)', @$el)
    @$repost_reply_container = ($ '.reply-container.repost-reply-container', @$el)

    for k, el of @$buttons
      do (k, el) =>
        el.off("click.#{k}").on "click.#{k}", (e) =>
          e.preventDefault()
          if msg = el.attr 'data-confirm'
            return false unless confirm(msg)
          @[k]?()
          false

  delete: =>
    @$el.hide()
    @post.destroy
      success: =>
        @$el.remove()
        if @post.isRepost() and (repost = @post.get('repost'))
          TentStatus.Reposted.unsetReposted(repost.get('id'), repost.get('entity'))
      error: => @$el.show()

  delete_repost: =>
    return unless repost = @post.get('repost')
    @$el.hide()
    repost.destroy
      error: => @$el.show()

  repost_repost: =>
    return unless repost = @post.get('repost')
    @repost(repost)

  repost: (post=@post) =>
    data = {
      permissions:
        public: true
      type: 'https://tent.io/types/post/repost/v0.1.0'
      content:
        entity: post.get('entity')
        id: post.get('id')
    }

    new HTTP 'POST', "#{TentStatus.config.tent_api_root}/posts", data, (repost, xhr) =>
      return unless xhr.status == 200
      repost = new TentStatus.Models.Post repost
      TentStatus.Reposted.setReposted(post.get('id'), post.get('entity'))

      if TentStatus.config.current_entity.assertEqual(TentStatus.config.domain_entity)
        @parentView.posts.unshift(repost)
        TentStatus.Views.Post.insertNewPost(repost, @parentView.$el, @parentView)

  reply_repost: =>
    @$repost_reply_container.toggle()

  reply: =>
    @$reply_container.toggle()

  repostContext: (post, repost) =>
    return false unless post.isRepost()

    repost ?= post.get('repost')
    return false unless repost
    return false if post.get('id') == repost.get('id')
    _.extend( @context(repost), {
      parent: { name: post.name(), id: post.get('id') }
      has_parent: true
    })

  postProfileJSON: (post) =>
    hasName: post.get('profile')?.hasName() || false
    name: post.get('profile')?.name() || ''
    avatar: post.get('profile')?.avatar() || ''

  inReplyToJSON: (mention) =>
    return unless mention
    {
      name: mention.entity,
      url: TentStatus.Helpers.entityPostUrl(mention.entity, mention.post)
    }

  context: (post = @post, repostContext) =>
    _.extend super, post.toJSON(), @postProfileJSON(post), {
      is_repost: post.isRepost()
      repost: repostContext || @repostContext(post)
      in_reply_to: @inReplyToJSON(post.postMentions()[0])
      url: TentStatus.Helpers.postUrl(post)
      profileUrl: TentStatus.Helpers.entityProfileUrl(post.get 'entity')
      licenses: _.map post.get('licenses') || [], (url) => { name: TentStatus.Helpers.formatUrl(url), url: url }
      escaped:
        entity: encodeURIComponent( post.get 'entity' )
      formatted:
        content:
          text: TentStatus.Helpers.autoLinkText(post.get('content')?.text)
        entity: TentStatus.Helpers.formatUrl post.get('entity')
        published_at: TentStatus.Helpers.formatTime post.get('published_at')
        full_published_at: TentStatus.Helpers.rawTime post.get('published_at')
      currentUserOwnsPost: TentStatus.config.current_entity.assertEqual( new HTTP.URI post.get('entity') )
    }

  render: (context = @context()) =>
    # wait for template to be loaded
    if @templateName
      unless @template
        @once 'template:load', => @render(arguments...)
        return false

    html = @template.render(context, @parentView.partials)
    el = ($ html)
    @$el.replaceWith(el)
    @setElement el
    @trigger 'ready'

