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

    @repost_enabled = true

    if @post
      @initPostEvents()
    else
      @once 'change:post', @initPostEvents

    @once 'ready', @fetchRepost
    @on 'ready', @bindEvents

    super

  initPostEvents: =>
    @post.on 'change:profile', => @render()
    @post.on 'change:disable_repost', => @render()

    @render() if @post.get('repost')?.get('profile')
    @render() if @post.get('profile')

  fetchRepost: =>
    if @post?.isRepost()
      @post.on 'repost:fetch:failed', =>
        @$el.hide()

      @post.on 'change:repost', =>
        repost = @post.get('repost')
        repost.on 'change:profile', => @render()
        repost.on 'change:disable_repost', => @render()
        @render()
        @$el.show()
      unless @post.get('repost')
        @$el.hide()
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

    for k, el of @$buttons
      do (k, el) =>
        el.off("click.#{k}").on "click.#{k}", (e) =>
          e.preventDefault()
          if msg = el.attr 'data-confirm'
            return false unless confirm(msg)
          @[k]?()
          false

    ## Show/Hide conversation view
    @details_view = null
    @details_view = @parentView if @parentView.view_name == 'post_details'

    touch_details = {}
    tag_blacklist = ['a', 'textarea', 'input']
    @$el.off('touchstart.toggle_details').on 'touchstart.toggle_details', (e) =>
      [touch_details.scrollX, touch_details.scrollY] = [window.scrollX, window.scrollY]

    @$el.off('touchend.toggle_details').on 'touchend.toggle_details', (e) =>
      return true unless (!(_.find tag_blacklist, (t)=> t == e.target.tagName.toLowerCase()) && !(_.find $(e.target).parents(), (el) => _.find(tag_blacklist, (t) => t == el.tagName.toLowerCase())) && touch_details.scrollX == window.scrollX && touch_details.scrollY == window.scrollY)
      e.preventDefault()
      @toggleDetails()
      false

    @$el.off('mousedown.toggle_details').on 'mousedown.toggle_details', (e) =>
      [touch_details.pageX, touch_details.pageY] = [e.pageX, e.pageY]

    @$el.off('click.toggle_details').on 'click.toggle_details', (e) =>
      return unless touch_details.pageX == e.pageX && touch_details.pageY == e.pageY
      return if (_.find tag_blacklist, (t)=> t == e.target.tagName.toLowerCase()) ||
                (_.find $(e.target).parents(), (el) => _.find(tag_blacklist, (t) => t == el.tagName.toLowerCase()))
      @toggleDetails()

  toggleDetails: =>
    if @details_view
      @hideDetails()
    else
      @showDetails()

  hideDetails: =>
    @details_view.unbind()
    @details_view.parentView.render()

  showDetails: =>
    return if @parentView.view_name == 'conversation'
    return if @details_view
    @details_view = new TentStatus.Views.PostDetails parentView: @

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
    return unless @repost_enabled
    @repost_enabled = false

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

  getRepostReplyPostForm: =>
    _.find @child_views?.ReplyPostForm || [], (i) -> i.is_repost

  getReplyPostForm: =>
    _.find @child_views?.ReplyPostForm || [], (i) -> !i.is_repost

  reply_repost: =>
    repost_reply_post_form = @getRepostReplyPostForm()
    repost_reply_post_form.toggle()

  reply: =>
    reply_post_form = @getReplyPostForm()
    reply_post_form.toggle()

  repostContext: (post, repost) =>
    return false unless post.isRepost()

    repost ?= post.get('repost')
    return false unless repost
    return false if post.get('id') == repost.get('id')
    _.extend( @context(repost), {
      parent: { name: post.name(), id: post.get('id'), app: post.get('app') }
      has_parent: true
    })

  postProfileJSON: (post) =>
    hasName: post.get('profile')?.hasName() || false
    name: post.get('profile')?.name() || ''
    avatar: post.get('profile')?.avatar() || ''

  inReplyToJSON: (mention) =>
    return unless mention
    {
      name: TentStatus.Helpers.formatUrlWithPath(mention.entity),
      url: TentStatus.Helpers.entityPostUrl(mention.entity, mention.post)
    }

  getReplyToEntities: (post) =>
    _entities = []
    for m in [{ entity: post.get('entity') }, post.postMentions()[0]].concat(TentStatus.Helpers.extractMentionsWithIndices(post.get('content')?.text || ''))
      continue unless m
      continue unless m.entity
      continue if @isCurrentUserEntity(m.entity)
      _entity =  TentStatus.Helpers.minimalEntity(m.entity)
      _entities.push(_entity) if _entities.indexOf(_entity) == -1
    _entities

  isCurrentUserEntity: (entity) =>
    return false unless TentStatus.config.current_entity
    TentStatus.config.current_entity.assertEqual( new HTTP.URI entity )

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
        reply_to_entities: @getReplyToEntities(post)
        content:
          text: TentStatus.Helpers.simpleFormatText(
            TentStatus.Helpers.autoLinkText(TentStatus.Helpers.truncate(post.get('content')?.text, TentStatus.config.MAX_LENGTH, ''))
          )
        entity: TentStatus.Helpers.formatUrl post.get('entity')
        published_at: TentStatus.Helpers.formatRelativeTime post.get('published_at')
        full_published_at: TentStatus.Helpers.rawTime post.get('published_at')
      currentUserOwnsPost: @isCurrentUserEntity(post.get 'entity')
      max_chars: TentStatus.config.MAX_LENGTH
    }

  renderHTML: (context, partials, template=(@template || partials['_post'])) =>
    template.render(context, partials)

  render: (context = @context()) =>
    # wait for template to be loaded
    if @templateName
      unless @template
        @once 'template:load', => @render(arguments...)
        return false

    html = @renderHTML(context, @parentView.partials)
    el = ($ html)
    @$el.replaceWith(el)
    @setElement el
    @trigger 'ready'

